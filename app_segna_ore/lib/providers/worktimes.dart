import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/worktime.dart';
import '../models/material.dart' as carl;
import '../models/actiontype.dart';
import '../models/actor.dart';
import '../models/box.dart';
import '../models/task.dart';
import '../errors/http_exception.dart';
import '../errors/http_wooccupationdateexception.dart';

class WorkTimes with ChangeNotifier {
  final String authToken;
  final Actor user;
  final String urlAmbiente;

  List<WorkTime> _workTimes = [];

  WorkTimes(this.urlAmbiente, this.authToken, this.user, this._workTimes);

  // Per gestire i log
  var logger = Logger();

  // Lista dei WorkTime
  List<WorkTime> get workTimes {
    return [..._workTimes];
  }

  // Lista dei WorkTime giornalieri
  List<WorkTime> workTimesDaily(DateTime giorno) {
    logger.d('Filtro WorkTimes giorno: $giorno');
    return _workTimes
        .where((workTime) =>
            DateTime(
              workTime.data.year,
              workTime.data.month,
              workTime.data.day,
            ) ==
            giorno)
        .toList();
  }

  // Recupera un WO per ID
  WorkTime findById(String id) {
    return _workTimes.firstWhere((workTime) => workTime.id == id);
  }

  // Recupera il numero di WO
  int get itemCount {
    return _workTimes.length;
  }

  // Calcolo ore registrate per singolo giorno
  double oreSegnate(DateTime giorno) {
    double oreSegnate = 0.0;
    for (var index = 0; index < itemCount; index++) {
      if (DateTime(_workTimes[index].data.year, _workTimes[index].data.month,
              _workTimes[index].data.day) ==
          DateTime(giorno.year, giorno.month, giorno.day)) {
        oreSegnate =
            oreSegnate + (_workTimes[index].tempoFatturato.inMinutes / 60);
      }
    }
    return oreSegnate;
  }

  // Funzione per dividere le ore registrate in una lista di giorni su base mensile
  List<Map> impostaMese(DateTime mese) {
    List<Map> giorniLavorativi = [];
    DateTime indexDay = DateTime(mese.year, mese.month, 1);
    if (indexDay.weekday != 1 && indexDay.weekday < 6) {
      giorniLavorativi = List.generate(
          indexDay.weekday - 1,
          (index) => {
                "numeroGiorno": "",
                "oreRegistrate": "",
              });
    }

    for (indexDay;
        indexDay.month == mese.month;
        indexDay = indexDay.add(const Duration(days: 1))) {
      if (indexDay.weekday < 6) {
        giorniLavorativi.add({
          "numeroGiorno": indexDay.toIso8601String(),
          "oreRegistrate": oreSegnate(indexDay).toString(),
        });
      }
    }
    return giorniLavorativi;
  }

  // Funzione per calcolare i carichi di lavoro per le commesse
  List<Map<String, dynamic>> calcolaCarichi() {
    Color coloreCasuale() {
      Random random = Random();
      return Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    }

    // Lista che conterrà i carichi di lavoro per le commesse
    List<Map<String, dynamic>> caricoXCommessa = [];

    // Variabile per tenere traccia del totale delle ore
    double oreTot = 0;

    // Ciclo per iterare attraverso ogni worktime e catalogarli per commessa
    for (var workTime in _workTimes) {
      // Aggiungi le ore del worktime al totale delle ore
      oreTot += workTime.tempoFatturato.inMinutes / 60;

      // Controlla se la commessa esiste già nella lista dei carichi di lavoro
      var existingCommessaIndex = caricoXCommessa.indexWhere(
          (element) => element['commessa'] == workTime.commessa.description);

      // Se la commessa non esiste, aggiungila alla lista dei carichi di lavoro
      if (existingCommessaIndex == -1) {
        caricoXCommessa.add({
          'commessa': workTime.commessa.description,
          'oreRegistrate': workTime.tempoFatturato.inMinutes / 60,
        });
      }
      // Se la commessa esiste già, aggiorna le ore registrate per quella commessa
      else {
        caricoXCommessa[existingCommessaIndex]['oreRegistrate'] +=
            workTime.tempoFatturato.inMinutes / 60;
      }
    }

    // Calcola la percentuale di carico per ogni commessa
    for (var commessa in caricoXCommessa) {
      commessa['caricoPercentuale'] = double.parse(
          ((commessa['oreRegistrate'] / oreTot) * 100).toStringAsFixed(2));
      commessa['colore'] = coloreCasuale();
    }

    // Ordina la lista in base alle ore registrate (dalla commessa con più ore a quella con meno)
    caricoXCommessa
        .sort((a, b) => b['oreRegistrate'].compareTo(a['oreRegistrate']));

    // Restituisci la lista dei carichi di lavoro
    return caricoXCommessa;
  }

  // Funzione per calcolare le ore fatturate
  List<Map> calcolaPercentualeFatturazione() {
    // Variabile per tenere traccia del totale delle ore e di quelle fatturate
    double oreTot = 0;
    double oreFatturate = 0;

    List<Map> lista = [];

    // Lista delle commesse che non devono essere calcolate per la fatturazione percentuale
    List<String> listaCommesseDaNonContare = [
      'Malattia',
      'Ferie - Permesso',
      'Donazione sangue',
      'Maternità',
    ];

    if (_workTimes.length == 0) {
      return lista;
    }

    // Ciclo per iterare attraverso ogni worktime e catalogarli per commessa
    for (var workTime in _workTimes) {
      // Controllo che la commessa sia da calcolare nella fatturazione
      if (!listaCommesseDaNonContare.contains(workTime.commessa.description)) {
        // Aggiungi le ore del worktime al totale delle ore
        oreTot += workTime.tempoFatturato.inMinutes / 60;
      }

      // Se la commessa NON è di Injenia allora le conto come ore fatturate
      if (!workTime.commessa.code.startsWith("INJ")) {
        oreFatturate += workTime.tempoFatturato.inMinutes / 60;
      }
    }

    double oreNonFatturate = oreTot - oreFatturate;

    double percentualeFatturato =
        double.parse(((oreFatturate / oreTot) * 100).toStringAsFixed(2));

    double percentualeNonFatturato =
        double.parse((100 - percentualeFatturato).toStringAsFixed(2));

    lista = [
      {
        'ore': oreFatturate,
        'percentuale': percentualeFatturato,
        'titolo': 'Fatturato',
        'colore': Colors.orange,
      },
      {
        'ore': oreNonFatturate,
        'percentuale': percentualeNonFatturato,
        'titolo': 'Non Fatturato',
        'colore': Colors.grey,
      },
    ];

    // Restituisci il totale ore e la percentuale
    return lista;
  }

  // Funzione per estrarre le nature tramite richiesta get
  Future<void> fetchAndSetWorkTimes([String? periodoRiferimento]) async {
    // Inizializzazione lista vuota
    final List<WorkTime> loadedWorkTimes = [];

    // Definizione dell'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
    };

    // Definizione del link della chiamata
    var url = Uri.parse(
      periodoRiferimento == null
          ? '$urlAmbiente/api/entities/v1/occupation?fields=occupationDate,duration,note,&include=technician,commessa,WO&filter[technician.code]=${user.code}&sort=-occupationDate'
          : '$urlAmbiente/api/entities/v1/occupation?fields=occupationDate,duration,note,&include=technician,commessa,WO&filter[technician.code]=${user.code}&sort=-occupationDate',
    );

    // Preparazione del try-catch degli errori
    try {
      // Creazione della chiamata per estrarre i WorkTimes
      var response = await http.get(
        url,
        headers: headers,
      );
      // Estrazione del risultato della chiamata
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      // Se non sono presenti WO esco dalla funzione
      if (extractedData['data'] == null) {
        return;
      }

      Actor attore = Actor(
        id: user.id,
        code: user.code,
        nome: user.nome,
      );

      // Iterazione per ogni risultato
      for (var occupation in extractedData['data']) {
        // Definisco il materiale nullo
        var material = carl.Material(
          id: null,
          code: '',
          description: '',
          eqptType: '',
          statusCode: '',
        );

        // Definisco il WO nullo
        var task = Task(
          id: null,
          code: '',
          description: '',
          statusCode: '',
          actionType: ActionType(
            id: null,
            code: '',
            description: '',
          ),
          cliente: Box(
            id: null,
            code: '',
            description: '',
            eqptType: '',
            statusCode: '',
          ),
          commessa: carl.Material(
            id: null,
            code: '',
            description: '',
            eqptType: '',
            statusCode: '',
          ),
          stima: const Duration(
            hours: 0,
            minutes: 0,
          ),
          dataInizio: DateTime.now(),
          dataFine: DateTime.now(),
          note: '',
          workflowTransitions: [],
        );

        // Recupero del materiale associato alla occupazione
        for (var record in extractedData['included']) {
          // Controllo che il materiale non sia nullo
          if (occupation['relationships']['commessa']['data'] != null) {
            // Controllo il material collegato
            if (record['id'] ==
                occupation['relationships']['commessa']['data']['id']) {
              // Definizione Material associato
              material = carl.Material(
                id: record['id'],
                code: record['attributes']['code'],
                description: record['attributes']['description'] ?? '',
                eqptType: record['attributes']['eqptType'],
                statusCode: record['attributes']['statusCode'],
              );
            }
          }

          // Controllo che il WO non sia nullo
          if (occupation['relationships']['WO']['data'] != null) {
            // Controllo il WO collegato
            if (record['id'] ==
                occupation['relationships']['WO']['data']['id']) {
              // Definisco il WO associato
              task = Task(
                id: record['id'],
                code: record['attributes']['code'],
                description: record['attributes']['description'],
                statusCode: record['attributes']['statusCode'],
                actionType: ActionType(
                  id: null,
                  code: '',
                  description: '',
                ),
                cliente: Box(
                  id: null,
                  code: '',
                  description: '',
                  eqptType: '',
                  statusCode: '',
                ),
                commessa: carl.Material(
                  id: null,
                  code: '',
                  description: '',
                  eqptType: '',
                  statusCode: '',
                ),
                stima: const Duration(
                  hours: 0,
                  minutes: 0,
                ),
                dataInizio: DateTime.parse(record['attributes']['WOBegin']),
                dataFine: DateTime.parse(record['attributes']['WOEnd']),
                note: record['attributes']['xtraTxt10'],
                workflowTransitions: [],
              );
            }
          }
        }

        logger.d(
            'data: ${occupation['attributes']['occupationDate']}, note: ${occupation['attributes']['note']}');

        // Aggiunta WorkTime alla lista
        loadedWorkTimes.add(
          WorkTime(
            id: occupation['id'],
            attore: attore,
            note: occupation['attributes']['note'] ?? '',
            data: DateTime.parse(occupation['attributes']['occupationDate'])
                .add(const Duration(hours: 1)),
            tempoFatturato: Duration(
                minutes: (occupation['attributes']['duration'] * 60).toInt()),
            commessa: material,
            task: task,
          ),
        );
      }
    } catch (error) {
      logger.d(error.toString());
      throw error;
    } finally {
      // Aggiorno la lista di WO
      _workTimes = loadedWorkTimes;
      notifyListeners();
    }
  }

  // Funzione per estrarre le nature tramite richiesta get
  Future<void> fetchAndSetFilteredWorkTimes([Map? filtro]) async {
    // Inizializzazione lista vuota
    final List<WorkTime> loadedWorkTimes = [];

    // Definizione dell'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
    };

    String? endpoint;

    logger.d('Filtro: $filtro');

    if (filtro != null) {
      if (filtro.containsKey("wo_id")) {
        String wo = filtro['wo_id'];

        endpoint =
            '$urlAmbiente/api/entities/v1/occupation?fields=occupationDate,duration,note&include=technician,commessa,WO&filter[technician.code]=${user.code}&filter[WO.id]=$wo&sort=-occupationDate';
      }
      if (filtro.containsKey("periodoCompetenza")) {
        String periodoCompetenza = filtro['periodoCompetenza'];

        endpoint =
            '$urlAmbiente/api/entities/v1/occupation?fields=occupationDate,duration,note&include=technician,commessa,WO&filter[technician.code]=${user.code}&filter[occupationDate][LIKE]=$periodoCompetenza&sort=-occupationDate';
      }
    } else {
      endpoint =
          '$urlAmbiente/api/entities/v1/occupation?fields=occupationDate,duration,note&include=technician,commessa,WO&filter[technician.code]=${user.code}&sort=-occupationDate';
    }

    // Definizione del link della chiamata
    var url = Uri.parse(endpoint!);

    // Preparazione del try-catch degli errori
    try {
      // Creazione della chiamata per estrarre i WorkTimes
      var response = await http.get(
        url,
        headers: headers,
      );
      // Estrazione del risultato della chiamata
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      // Se non sono presenti WO esco dalla funzione
      if (extractedData['data'] == null) {
        return;
      }

      Actor attore = Actor(
        id: user.id,
        code: user.code,
        nome: user.nome,
      );

      // Iterazione per ogni risultato
      for (var occupation in extractedData['data']) {
        // Definisco il materiale nullo
        var material = carl.Material(
          id: null,
          code: '',
          description: '',
          eqptType: '',
          statusCode: '',
        );

        // Definisco il WO nullo
        var task = Task(
          id: null,
          code: '',
          description: '',
          statusCode: '',
          actionType: ActionType(
            id: null,
            code: '',
            description: '',
          ),
          cliente: Box(
            id: null,
            code: '',
            description: '',
            eqptType: '',
            statusCode: '',
          ),
          commessa: carl.Material(
            id: null,
            code: '',
            description: '',
            eqptType: '',
            statusCode: '',
          ),
          stima: const Duration(
            hours: 0,
            minutes: 0,
          ),
          dataInizio: DateTime.now(),
          dataFine: DateTime.now(),
          note: '',
          workflowTransitions: [],
        );

        // Recupero del materiale associato alla occupazione
        for (var record in extractedData['included']) {
          // Controllo che il materiale non sia nullo
          if (occupation['relationships']['commessa']['data'] != null) {
            // Controllo il material collegato
            if (record['id'] ==
                occupation['relationships']['commessa']['data']['id']) {
              // Definizione Material associato
              material = carl.Material(
                id: record['id'],
                code: record['attributes']['code'],
                description: record['attributes']['description'] ?? '',
                eqptType: record['attributes']['eqptType'],
                statusCode: record['attributes']['statusCode'],
              );
            }
          }

          // Controllo che il WO non sia nullo
          if (occupation['relationships']['WO']['data'] != null) {
            // Controllo il WO collegato
            if (record['id'] ==
                occupation['relationships']['WO']['data']['id']) {
              // Definisco il WO associato
              task = Task(
                id: record['id'],
                code: record['attributes']['code'],
                description: record['attributes']['description'],
                statusCode: record['attributes']['statusCode'],
                actionType: ActionType(
                  id: null,
                  code: '',
                  description: '',
                ),
                cliente: Box(
                  id: null,
                  code: '',
                  description: '',
                  eqptType: '',
                  statusCode: '',
                ),
                commessa: carl.Material(
                  id: null,
                  code: '',
                  description: '',
                  eqptType: '',
                  statusCode: '',
                ),
                stima: const Duration(
                  hours: 0,
                  minutes: 0,
                ),
                dataInizio: DateTime.parse(record['attributes']['WOBegin']),
                dataFine: DateTime.parse(record['attributes']['WOEnd']),
                note: record['attributes']['xtraTxt10'],
                workflowTransitions: [],
              );
            }
          }
        }

        // Aggiunta WorkTime alla lista
        loadedWorkTimes.add(
          WorkTime(
            id: occupation['id'],
            attore: attore,
            note: occupation['attributes']['note'] ?? '',
            data: DateTime(
              DateTime.parse(occupation['attributes']['occupationDate']).year,
              DateTime.parse(occupation['attributes']['occupationDate']).month,
              DateTime.parse(occupation['attributes']['occupationDate'])
                  .add(const Duration(hours: 2))
                  .day, // Aggiungo 2 ore per essere sicuro di prendere il giorno giusto
              12,
              0,
              0,
            ),
            tempoFatturato: Duration(
                minutes: (occupation['attributes']['duration'] * 60).toInt()),
            commessa: material,
            task: task,
          ),
        );
      }
    } catch (error) {
      logger.d(error.toString());
      throw error;
    } finally {
      // Aggiorno la lista di WO
      _workTimes = loadedWorkTimes;
      notifyListeners();
    }
  }

  Future<void> addWorkTime(WorkTime workTime, {int index = 0}) async {
    logger.d('Funzione addWorkTime');

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final url = Uri.parse('$urlAmbiente/api/entities/v1/occupation');

    final data = json.encode(workTime.task!.id != null
        ? {
            'data': {
              'type': 'occupation',
              'attributes': {
                'UOwner': user.code,
                'note': workTime.note,
                'occupationDate':
                    "${DateTime(workTime.data.year, workTime.data.month, workTime.data.day, 12).toIso8601String().substring(0, 23)}+01:00",
                'duration': (workTime.tempoFatturato.inMinutes / 60),
              },
              'relationships': {
                "WO": {
                  "data": {
                    "type": "wo",
                    "id": workTime.task!.id,
                  }
                },
                "technician": {
                  "data": {
                    "type": "technician",
                    "id": user.tecnicoID,
                  }
                },
                "commessa": {
                  "data": {
                    "type": "material",
                    "id": workTime.commessa.id,
                  }
                }
              }
            }
          }
        : {
            'data': {
              'type': 'occupation',
              'attributes': {
                'UOwner': user.code,
                'note': workTime.note,
                'occupationDate':
                    "${DateTime(workTime.data.year, workTime.data.month, workTime.data.day, 12).toIso8601String().substring(0, 23)}+01:00",
                'duration': (workTime.tempoFatturato.inMinutes / 60),
              },
              'relationships': {
                "occupationType": {
                  "data": {
                    "type": "occupationtype",
                    "id": "185720e8249-6698e",
                  }
                },
                "technician": {
                  "data": {
                    "type": "technician",
                    "id": user.tecnicoID,
                  }
                },
                "commessa": {
                  "data": {
                    "type": "material",
                    "id": workTime.commessa.id,
                  }
                }
              }
            }
          });

    //logger.d(url);
    try {
      final response = await http.post(
        url,
        body: data,
        headers: headers,
      );

      logger.d(
          'Stato occupation: ${json.decode(response.statusCode.toString())}');

      if (response.statusCode >= 400) {
        if (json.decode(response.body)['errors'][0]['code'] ==
            'com.carl.xnet.works.backend.exceptions.WOOccupationDateExceptions') {
          throw HttpWOOccupationDateException(
            json.decode(response.body)['errors'][0]['title'].toString(),
          );
        } else {
          throw HttpException(
            json.decode(response.body)['errors'][0]['title'].toString(),
          );
        }
        //com.carl.xnet.works.backend.exceptions.WOOccupationDateExceptions
      }

      workTime.id = json.decode(response.body)['data']['id'];

      _workTimes.insert(index, workTime);
      notifyListeners();
    } catch (error) {
      logger.d(error);
      throw error;
    }
  }

  Future<void> updateWorkTime(
      String id, WorkTime initWorkTime, WorkTime newWorkTime,
      {int index = 0}) async {
    final workTimeIndex =
        _workTimes.indexWhere((worktime) => worktime.id == id);

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final url = Uri.parse('$urlAmbiente/api/entities/v1/occupation/$id');

    final data = json.encode(
      newWorkTime.task!.id != null
          ? {
              'data': {
                'type': 'occupation',
                'attributes': {
                  'UOwner': user.code,
                  'note': newWorkTime.note,
                  'occupationDate':
                      "${DateTime(newWorkTime.data.year, newWorkTime.data.month, newWorkTime.data.day, 12).toIso8601String().substring(0, 23)}+01:00",
                  'duration': (newWorkTime.tempoFatturato.inMinutes / 60),
                },
                'relationships': {
                  "WO": {
                    "data": {
                      "type": "wo",
                      "id": newWorkTime.task!.id,
                    }
                  },
                  "technician": {
                    "data": {
                      "type": "technician",
                      "id": user.tecnicoID,
                    }
                  },
                  "commessa": {
                    "data": {
                      "type": "material",
                      "id": newWorkTime.commessa.id,
                    }
                  }
                }
              }
            }
          : {
              'data': {
                'type': 'occupation',
                'attributes': {
                  'UOwner': user.code,
                  'note': newWorkTime.note,
                  'occupationDate':
                      "${DateTime(newWorkTime.data.year, newWorkTime.data.month, newWorkTime.data.day, 12).toIso8601String().substring(0, 23)}+01:00",
                  'duration': (newWorkTime.tempoFatturato.inMinutes / 60),
                },
                'relationships': {
                  "occupationType": {
                    "data": {
                      "type": "occupationtype",
                      "id": "185720e8249-6698e",
                    }
                  },
                  "technician": {
                    "data": {
                      "type": "technician",
                      "id": user.tecnicoID,
                    }
                  },
                  "commessa": {
                    "data": {
                      "type": "material",
                      "id": newWorkTime.commessa.id,
                    }
                  }
                }
              }
            },
    );

    if (workTimeIndex >= 0) {
      try {
        final response = await http.patch(
          url,
          body: data,
          headers: headers,
        );

        logger.d(
          'Stato occupation: ${json.decode(response.statusCode.toString())}',
        );

        if (response.statusCode >= 400) {
          throw HttpException(
            json.decode(response.body)['errors'][0]['title'].toString(),
          );
        }

        _workTimes[workTimeIndex] = newWorkTime;

        notifyListeners();
      } catch (error) {
        logger.d(error);
        throw error;
      }
    }
  }

  Future<void> deleteWorkTime(String workTimeID) async {
    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final url =
        Uri.parse('$urlAmbiente/api/entities/v1/occupation/$workTimeID');
    //logger.d(urlDeleteWoEqpt);

    final response = await http.delete(
      url,
      headers: headers,
    );
    logger.d('Stato delete WorkTime: ${response.statusCode}');

    if (response.statusCode >= 400) {
      throw HttpException(
        json.decode(response.body)['errors'][0]['title'].toString(),
      );
    }

    _workTimes.removeWhere((workTime) => workTime.id == workTimeID);
    notifyListeners();
  }
}
