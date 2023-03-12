import 'dart:async';
import 'dart:convert';
import 'package:app_segna_ore/providers/actor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _urlAmbiente;
  String _token;
  Actor _user;

  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String get urlAmbiente {
    return _urlAmbiente;
  }

  Actor get user {
    return _user;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
    String urlAmbiente,
    String username,
    String password,
  ) async {
    var url = Uri.parse(
        '$urlAmbiente/api/auth/v1/authenticate?login=$username&password=$password&origin=Postman_SCA'); // Per eseguire l'autenticazione
    try {
      var response = await http.post(url);

      if (response.statusCode >= 400) {
        throw HttpException('Le credenziali non sono valide');
      }

      print(json.decode(response.body));

      var responseData = json.decode(response.body);

      _urlAmbiente = urlAmbiente;
      _token = responseData['X-CS-Access-Token'];
      _expiryDate = DateTime.now().add(
        const Duration(seconds: 432000),
      );

      try {
        url = Uri.parse(
            '$urlAmbiente/api/entities/v1/user?filter[login]=$username');
        response = await http.get(
          url,
          headers: {
            "X-CS-Access-Token": _token,
          },
        );
        responseData = json.decode(response.body);
        //print(responseData);

        var url_actor = Uri.parse(responseData['data'][0]['relationships']
            ['actor']['links']['related']);
        response = await http.get(
          url_actor,
          headers: {
            "X-CS-Access-Token": _token,
          },
        );
        responseData = json.decode(response.body);

        var actorID = responseData['data']['id'];
        var actorNome = responseData['data']['attributes']['fullName'];

        var url_technician = Uri.parse(
            '$urlAmbiente/api/entities/v1/technician?filter[code]=$username');
        response = await http.get(
          url_technician,
          headers: {
            "X-CS-Access-Token": _token,
          },
        );
        responseData = json.decode(response.body);

        var technicianID = responseData['data'][0]['id'];

        _user = Actor(
          id: actorID,
          code: username,
          nome: actorNome,
          tecnicoID: technicianID,
        );

        notifyListeners();
      } catch (error) {
        print(error);
        throw error;
      }
      notifyListeners();
      _autoLogout();

      print(
          'Autenticazione: Token: $_token, ActorID: ${_user.id}, ActorCode: ${_user.code}, AmbienteUrl: $_urlAmbiente, Data scadenza: ${_expiryDate.toString()}');

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'url': _urlAmbiente,
          'token': _token,
          'user': {
            'id': _user.id,
            'code': _user.code,
            'nome': _user.nome,
            'tecnicoID': _user.tecnicoID,
          },
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      print(userData);

      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(
      String urlAmbiente, String username, String password) async {
    return _authenticate(urlAmbiente, username, password);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    print('Dati sul dispositivo: ${json.decode(prefs.getString('userData'))}');
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _urlAmbiente = extractedUserData['url'];
    _token = extractedUserData['token'];
    Map utente = extractedUserData['user'];
    _user = Actor(
      id: utente['id'],
      code: utente['code'],
      nome: utente['nome'],
      tecnicoID: utente['tecnicoID'],
    );

    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  void logoout() async {
    _urlAmbiente = null;
    _token = null;
    _user = Actor(
      id: null,
      code: '',
      nome: '',
    );
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(
      {
        'url': null,
        'token': null,
        'user': null,
        'expiryDate': null,
      },
    );
    prefs.setString('userData', userData);
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logoout);
  }
}
