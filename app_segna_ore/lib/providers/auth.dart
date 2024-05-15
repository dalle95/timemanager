import 'dart:async';
import 'dart:convert';
import 'package:app_segna_ore/urlAmbiente.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/actor.dart';
import '../errors/http_exception.dart';

class Auth with ChangeNotifier {
  String? urlAmbiente;
  String? nome;

  Auth({
    this.urlAmbiente,
    this.nome,
  });

  // Per gestire i log
  var logger = Logger();

  Actor? _user;
  String? _token;
  DateTime? _refreshDate;

// Controllo se l'utente è loggato
  bool get isAuth {
    return _token != null;
  }

  // Recupero del token di autenticazione
  String? get token {
    return _token;
  }

  // Recupero dell'utente collegato
  Actor? get user {
    return _user;
  }

  // Recupero il nome utente
  String? get username {
    return nome;
  }

  void settaUsername(String username) {
    nome = username;
    notifyListeners();
  }

  // Funzione di autenticazione
  Future<void> _authenticate(
    String urlAmbiente,
    String username,
    String password,
  ) async {
    logger.d("Funzione authenticate");

    // Chiamata per autenticare l'utente richiedendo il token
    try {
      var url = Uri.parse(
          '$urlAmbiente/api/auth/v1/authenticate?login=$username&password=$password&origin=Postman_SCA'); // Per eseguire l'autenticazione

      var response = await http.post(url);

      // Gestione errore credenziali
      if (response.statusCode >= 400) {
        throw HttpException('Le credenziali non sono valide');
      }

      logger.d(json.decode(response.body));

      // Estrazione dati dalla risposta
      var responseData = json.decode(response.body);

      // Definizione variabili di autenticazione
      _token = responseData['X-CS-Access-Token'];
      _refreshDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      // Chiamata per estrarre le informazioni utente
      try {
        url = Uri.parse(
            '$urlAmbiente/api/entities/v1/user?include=actor&filter[login]=$username');
        response = await http.get(
          url,
          headers: {
            "X-CS-Access-Token": _token!,
          },
        );
        responseData = json.decode(response.body);

        logger.d(responseData);

        // Recupero dell'attore associato e definizione delle informazioni
        // Generali
        var actorID = responseData['included'][0]['id'];
        var actorNome = responseData['included'][0]['attributes']['fullName'];
        var actorCode = responseData['included'][0]['attributes']['code'];
        // Specifiche per questa app
        var technicianID;

        // Chiamata per estrarre il tecnico
        var url_technician = Uri.parse(
            '$urlAmbiente/api/entities/v1/technician?filter[code]=$actorCode');
        response = await http.get(
          url_technician,
          headers: {
            "X-CS-Access-Token": _token!,
          },
        );

        responseData = json.decode(response.body);

        logger.d(responseData);

        // Recupero il tecnico collegato
        technicianID = responseData['data'][0]['id'];

        // Definisco l'utente
        _user = Actor(
          id: actorID,
          code: actorCode,
          nome: actorNome,
          tecnicoID: technicianID,
        );

        notifyListeners();
      } catch (error) {
        logger.d(error);
        throw error;
      }
      notifyListeners();

      logger.d(
        'Autenticazione: Token: $_token, ActorID: ${_user!.id}, ActorCode: ${_user!.code}, AmbienteUrl: $urlAmbiente, Data scadenza: ${_refreshDate.toString()}',
      );

      // Preparo l'istanza FlutterSecureStorage per salvare i dati di autenticazione
      final storage = const FlutterSecureStorage();

      final userData = json.encode(
        {
          'token': _token,
          'username': username,
          'password': password,
          'user': {
            'id': _user!.id,
            'code': _user!.code,
            'nome': _user!.nome,
            'tecnicoID': _user!.tecnicoID,
          },
          'refreshDate': _refreshDate!.toIso8601String(),
        },
      );
      logger.d(userData);

      // Salvo i dati di autenticazione
      await storage.write(key: 'userData', value: userData);

      logger.d('Credenziali salvate');
    } catch (error) {
      throw error;
    }
  }

  // Funzione di login
  Future<void> login(
    String urlAmbiente,
    String username,
    String password,
  ) async {
    return _authenticate(
      urlAmbiente,
      username,
      password,
    );
  }

  // Funzione per il login automatico all'apertura dell'app
  Future<bool> tryAutoLogin() async {
    logger.d('Funzione tryAutoLogin');

    // Preparo l'istanza FlutterSecureStorage per recuperare i dati di autenticazione
    final storage = const FlutterSecureStorage();

    if (!await storage.containsKey(key: 'userData')) {
      logger.d('Nessun dato sul dispositivo');
      return false;
    }

    logger.d('Dati trovati');

    // Estrazione dei dati
    final extractedUserData =
        json.decode(await storage.read(key: 'userData') ?? '')
            as Map<String, dynamic>;

    logger.d(
      'Dati sul dispositivo: ${extractedUserData}',
    );

    // Recupero le informazioni principali
    final refreshDate = DateTime.parse(extractedUserData['refreshDate']);
    final username = extractedUserData['username'];
    final password = extractedUserData['password'];

    logger.d(refreshDate !=
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ));

    if (username != null && password != null) {
// Controllo la data di refresh del token: se non è di oggi rifaccio l'autenticazione
      if (refreshDate !=
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          )) {
        // Refresh del token
        await _authenticate(
          url.urlAmbiente,
          username,
          password,
        );
        return isAuth;
      }

      // Definizione dati di autenticazione
      _token = extractedUserData['token'];

      final utente = extractedUserData['user'];

      _user = Actor(
        id: utente['id'],
        code: utente['code'],
        nome: utente['nome'],
        tecnicoID: utente['tecnicoID'],
      );

      _refreshDate = refreshDate;

      notifyListeners();
      return true;
    }

    return false;
  }

  // Funzione per la disconnessione
  void logoout() async {
    logger.d('Funzione logout');
    // Inizializzo le variabili di autenticazione come nulle
    _token = null;
    _user = Actor(
      id: null,
      code: '',
      nome: '',
      tecnicoID: '',
    );
    _refreshDate = null;

    // Preparo l'istanza FlutterSecureStorage per aggiornare i dati di autenticazione
    final storage = const FlutterSecureStorage();

    final userData = json.encode(
      {
        'token': null,
        'username': null,
        'password': null,
        'user': null,
        'expiryDate': null,
      },
    );

    // Aggiorno i dati di autenticazione
    storage.write(key: 'userData', value: userData);

    notifyListeners();
  }
}
