import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _urlAmbiente;
  String _token;
  String _userId;
  String _actorName;

  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String get urlAmbiente {
    return _urlAmbiente;
  }

  String get userId {
    return _userId;
  }

  String get actorName {
    return _actorName;
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
      String urlAmbiente, String username, String password) async {
    var url = Uri.parse(
        '$urlAmbiente/api/auth/v1/authenticate?login=$username&password=$password&origin=Postman_SCA'); // Per eseguire l'autenticazione
    try {
      var response = await http.post(url);

      if (response.statusCode.toString() == '401') {
        throw HttpException('Le credenziali non sono valide');
      }

      print(json.decode(response.body));
      var responseData = json.decode(response.body);

      _urlAmbiente = urlAmbiente;
      _token = responseData['X-CS-Access-Token'];
      _expiryDate = DateTime.now().add(Duration(seconds: 604800));

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

        var url_actor = Uri.parse(responseData['data'][0]['relationships']
            ['actor']['links']['related']);
        response = await http.get(
          url_actor,
          headers: {
            "X-CS-Access-Token": _token,
          },
        );
        responseData = json.decode(response.body);
        _userId = responseData['data']['id'];
        _actorName = responseData['data']['attributes']['fullName'];

        print(_actorName);
      } catch (error) {
        print(error);
        throw error;
      }

      notifyListeners();
      _autoLogout();

      print(
          'Autenticazione: Token: $_token, ActorID: $_userId, AmbienteUrl: $_urlAmbiente, Data scadenza: ${_expiryDate.toString()}');

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'url': _urlAmbiente,
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
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
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  void logoout() async {
    _urlAmbiente = null;
    _token = null;
    _userId = null;
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
        'userId': null,
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
