import 'dart:convert';

import 'package:app_segna_ore/models/http_wooccupationdateexception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/worktime.dart';
import '../providers/material.dart' as carl;
import '../providers/actiontype.dart';
import '../providers/actor.dart';
import '../providers/box.dart';
import '../providers/task.dart';
import '../models/http_exception.dart';

class WorkTimes with ChangeNotifier {
  final String authToken;
  final Actor user;
  final String urlAmbiente;

  List<WorkTime> _workTimes = [];

  WorkTimes(this.urlAmbiente, this.authToken, this.user, this._workTimes);

  // Lista dei WO
  List<WorkTime> get workTimes {
    return [..._workTimes];
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
          giorno) {
        oreSegnate =
            oreSegnate + (_workTimes[index].tempoFatturato.inMinutes / 60);
      }
    }
    return oreSegnate;
  }

  List<Map> calcolaCarichi(List<WorkTime> worktimes) {
    List<Map> caricoXCommessa = [];
    double oreTot = 0;

    for (int index = 0; index < worktimes.length; index++) {
      if (caricoXCommessa
          .where((worktime) =>
              worktime['commessa'] == worktimes[index].commessa.description)
          .isEmpty) {
        caricoXCommessa.add(
          {
            'commessa': worktimes[index].commessa.description,
            'oreRegistrate': worktimes[index].tempoFatturato.inMinutes / 60,
          },
        );
      } else {
        int indice = caricoXCommessa.indexWhere((worktime) =>
            worktime['commessa'] == worktimes[index].commessa.description);

        caricoXCommessa[indice]['oreRegistrate'] = caricoXCommessa[indice]
                ['oreRegistrate'] +
            worktimes[indice].tempoFatturato.inMinutes / 60;
      }
    }

    for (int index = 0; index < caricoXCommessa.length; index++) {
      oreTot = oreTot + caricoXCommessa[index]['oreRegistrate'];
    }

    for (int index = 0; index < caricoXCommessa.length; index++) {
      caricoXCommessa[index] = {
        'commessa': caricoXCommessa[index]['commessa'],
        'oreRegistrate': caricoXCommessa[index]['oreRegistrate'],
        'caricoPercentuale': (caricoXCommessa[index]['oreRegistrate'] / oreTot),
      };
    }

    caricoXCommessa
        .sort((a, b) => a['oreRegistrate'].compareTo(b['oreRegistrate']));

    return caricoXCommessa.reversed.toList();
  }

  // Funzione per estrarre le nature tramite richiesta get
  Future<void> fetchAndSetWorkTimes([String periodoRiferimento]) async {
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

        print(
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
                    minutes:
                        (occupation['attributes']['duration'] * 60).toInt()) ??
                const Duration(
                  hours: 0,
                  minutes: 0,
                ),
            // tempoFatturato: parseDuration(occupation['attributes']['time02']) ??
            //     const Duration(
            //       hours: 0,
            //       minutes: 0,
            //     ),
            commessa: material,
            task: task,
          ),
        );

        // Ordino la lista in base al codice del WO
        //loadedWorkTimes.sort((a, b) => a.data.compareTo(b.data));

        //   },
        // );
      }
    } catch (error) {
      print(error.toString());
      throw error;
    } finally {
      // Aggiorno la lista di WO
      _workTimes = loadedWorkTimes;
      notifyListeners();
    }
  }

  // Funzione per estrarre le nature tramite richiesta get
  Future<void> fetchAndSetFilteredWorkTimes([Map filtro]) async {
    // Inizializzazione lista vuota
    final List<WorkTime> loadedWorkTimes = [];

    // Definizione dell'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
    };

    String endpoint;

    print(filtro);

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
      if (filtro.containsKey("giornoCompetenza")) {
        String periodoCompetenza = filtro['giornoCompetenza'];

        endpoint =
            '$urlAmbiente/api/entities/v1/occupation?fields=occupationDate,duration,note&include=technician,commessa,WO&filter[technician.code]=${user.code}&filter[occupationDate][LIKE]=$periodoCompetenza&sort=-occupationDate';
      }
    } else {
      endpoint =
          '$urlAmbiente/api/entities/v1/occupation?fields=occupationDate,duration,note&include=technician,commessa,WO&filter[technician.code]=${user.code}&sort=-occupationDate';
    }

    // Definizione del link della chiamata
    var url = Uri.parse(endpoint);

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
                    minutes:
                        (occupation['attributes']['duration'] * 60).toInt()) ??
                const Duration(
                  hours: 0,
                  minutes: 0,
                ),
            // tempoFatturato: parseDuration(occupation['attributes']['time02']) ??
            //     const Duration(
            //       hours: 0,
            //       minutes: 0,
            //     ),
            commessa: material,
            task: task,
          ),
        );

        // Ordino la lista in base al codice del WO
        //loadedWorkTimes.sort((a, b) => a.data.compareTo(b.data));

        //   },
        // );
      }
    } catch (error) {
      print(error.toString());
      throw error;
    } finally {
      // Aggiorno la lista di WO
      _workTimes = loadedWorkTimes;
      notifyListeners();
    }
  }

  Future<void> addWorkTime(WorkTime workTime, {int index = 0}) async {
    print('Funzione addWorkTime');

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final url = Uri.parse('$urlAmbiente/api/entities/v1/occupation');

    final data = json.encode(workTime.task.id != null
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
                    "id": workTime.task.id,
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

    //print(url);
    try {
      final response = await http.post(
        url,
        body: data,
        headers: headers,
      );

      print('Stato occupation: ${json.decode(response.statusCode.toString())}');

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
      print(error);
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
      newWorkTime.task.id != null
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
                      "id": newWorkTime.task.id,
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

        print(
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
        print(error);
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
    //print(urlDeleteWoEqpt);

    final response = await http.delete(
      url,
      headers: headers,
    );
    print('Stato delete WorkTime: ${response.statusCode}');

    if (response.statusCode >= 400) {
      throw HttpException(
        json.decode(response.body)['errors'][0]['title'].toString(),
      );
    }

    _workTimes.removeWhere((workTime) => workTime.id == workTimeID);
    notifyListeners();
  }
}
