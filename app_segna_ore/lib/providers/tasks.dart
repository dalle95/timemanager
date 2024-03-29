import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/task.dart';
import '../models/actiontype.dart';
import '../models/box.dart';
import '../models/material.dart' as carl;
import '../models/workflow_transitions.dart';

class Tasks with ChangeNotifier {
  final String authToken;
  final String userId;
  final String urlAmbiente;

  List<Task> _tasks = [];

  Tasks(this.urlAmbiente, this.authToken, this.userId, this._tasks);

  // Per gestire i log
  var logger = Logger();

  // Lista delle task
  List<Task> get tasks {
    return [..._tasks];
  }

  // Recupera un task per ID
  Task findById(String id) {
    return _tasks.firstWhere((Task) => Task.id == id);
  }

  // Recupera il numero di WO
  int get itemCount {
    return _tasks.length;
  }

  // Metodo per estrarre i task tramite richiesta http
  Future<void> fetchAndSetTasks([bool filterByUser = false]) async {
    // Definizione elenco Tasks
    final List<Task> loadedTasks = [];

    DateTime init = DateTime.now();

    // Inizializzazione Header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
    };

    // Definizione url per estrazione Task
    var url = Uri.parse(
        '$urlAmbiente/api/entities/v1/woresources?include=WO&filter[technician.actor.id]=$userId');

    try {
      // Creazione chiamata per estrazione Tasks
      var response = await http.get(
        url,
        headers: headers,
      );

      // Estrazione Tasks
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      // Se non sono presenti WO esco dalla funzione
      if (extractedData['included'] == null) {
        return;
      }

      // Iterazione per ogni risultato
      for (var wo in extractedData['included']) {
        if (wo['attributes']['statusCode'] == 'AWAITINGREAL' ||
            wo['attributes']['statusCode'] == 'INPROGRESS' ||
            wo['attributes']['statusCode'] == 'PAUSE') {
          // Inizializzazione natura vuota
          var actionType = ActionType(
            id: null,
            code: null,
            description: null,
          );

          // Definizione Url actionType
          var actionTypeUrl =
              Uri.parse(wo['relationships']['actionType']['links']['related']);

          // Creazione chiamata actionType
          var actionTypeResponse = await http.get(
            actionTypeUrl,
            headers: headers,
          );

          // Estrazione risultati
          var actionTypeData =
              json.decode(actionTypeResponse.body) as Map<String, dynamic>;

          // Assegnazione natura
          actionType = ActionType(
            id: actionTypeData['data']['id'],
            code: actionTypeData['data']['attributes']['code'],
            description: actionTypeData['data']['attributes']['description'],
          );

          // Inizializzazione del BOX  e material vuoto
          var boxLocation = Box(
            id: null,
            code: '',
            description: '',
            eqptType: '',
            statusCode: '',
          );
          var material = carl.Material(
            id: null,
            code: '',
            description: '',
            eqptType: '',
            statusCode: '',
          );

          try {
            // Definizione Url WOEqpt
            var woEqptUrl = Uri.parse(
                wo['relationships']['equipments']['links']['related']);

            // Creazione chiamata actionType
            var woEqptResponse = await http.get(
              woEqptUrl,
              headers: headers,
            );

            logger.d(woEqptUrl);

            // Estrazione risultati
            var woEqptData =
                json.decode(woEqptResponse.body) as Map<String, dynamic>;

            // Itero per i WOEqpt
            for (var woeqpt in woEqptData['data']) {
              // Controllo Box e Material associato al WO
              if (woeqpt['attributes']['directEqpt'] == true ||
                  woeqpt['attributes']['referEqpt'] == true) {
                // Controllo box collegato direttamente al WO
                if (woeqpt['attributes']['directEqpt'] == true &&
                    woeqpt['attributes']['referEqpt'] == false) {
                  // Definizione url BOX
                  var boxLocationUrl = Uri.parse(
                      woeqpt['relationships']['eqpt']['links']['related']);
                  // Creazione chiamata per estrazione BOX
                  var boxLocationResponse = await http.get(
                    boxLocationUrl,
                    headers: headers,
                  );
                  // Definizione risultati
                  var boxLocationdData = json.decode(boxLocationResponse.body)
                      as Map<String, dynamic>;

                  // Definizione del BOX associato
                  boxLocation = Box(
                    id: boxLocationdData['data']['id'],
                    code: boxLocationdData['data']['attributes']['code'],
                    description: boxLocationdData['data']['attributes']
                            ['description'] ??
                        '',
                    eqptType: boxLocationdData['data']['attributes']
                        ['eqptType'],
                    statusCode: boxLocationdData['data']['attributes']
                        ['statusCode'],
                  );
                }
              }

              // Controllo box collegato direttamente al WO
              if (woeqpt['attributes']['referEqpt'] == true) {
                // Definizione url Material
                var materialUrl = Uri.parse(woeqpt['relationships']['eqpt']
                        ['links']['related']
                    .toString());
                // Creazione chiamata per estrazione Material
                var materialResponse = await http.get(
                  materialUrl,
                  headers: headers,
                );
                // Estrazione risultati
                var materialData =
                    json.decode(materialResponse.body) as Map<String, dynamic>;

                // Definizione del Material associato
                material = carl.Material(
                  id: materialData['data']['id'],
                  code: materialData['data']['attributes']['code'],
                  description:
                      materialData['data']['attributes']['description'] ?? '',
                  eqptType: materialData['data']['attributes']['eqptType'],
                  statusCode: materialData['data']['attributes']['statusCode'],
                );
              }
            }

            // Inizializzo la lista di transizioni come lista vuota
            List<WorkflowTransitions> listWorkflowTransitions = [];

            logger.d(
                'wo_code: ${wo['attributes']['code']}, actiontype_code: ${actionType.code}, box_code: ${boxLocation.code}');

            // Aggiunta Task alla lista
            loadedTasks.add(
              Task(
                id: wo['id'],
                code: wo['attributes']['code'],
                description: wo['attributes']['description'] ?? '',
                statusCode: wo['attributes']['statusCode'],
                priority: wo['attributes']['workPriority'],
                actionType: actionType,
                cliente: boxLocation,
                commessa: material,
                note: wo['attributes']['xtraTxt10'],
                stima: Duration(
                  minutes: (wo['attributes']['expTime'] ?? 0 * 60).toInt(),
                ),
                dataInizio: DateTime.parse(wo['attributes']['WOBegin']),
                dataFine: DateTime.parse(wo['attributes']['WOEnd']),
                workflowTransitions: listWorkflowTransitions,
              ),
            );
          } catch (error) {
            throw error;
          } finally {
            // Orinamento lista in base al codice
            loadedTasks.sort((a, b) => a.code.compareTo(b.code));
          }
        }
      }
      //   },
      // );
    } catch (error) {
      logger.d(error.toString());
      throw error;
    } finally {
      // Aggiornamento lista
      _tasks = loadedTasks;
      notifyListeners();
    }

    DateTime end = DateTime.now();
    logger.d(end.difference(init).inMilliseconds);
  }

  Future<void> addTask(Task task, {int index = 0}) async {
    logger.d('Funzione addTask');

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final url =
        Uri.parse('$urlAmbiente/api/entities/v1/wo?filter[code][LIKE]=TM.');
    int numero = 0;

    String codiceWO;

    try {
      try {
        // Chiamata per contare i WO
        final response = await http.get(
          url,
          headers: headers,
        );

        logger
            .d('Stato GET wo: ${json.decode(response.statusCode.toString())}');

        if (response.statusCode >= 400) {
          throw HttpException(
            json.decode(response.body)['errors'][0]['title'].toString(),
          );
        } else {
          // Estrazione Tasks
          var extractedData =
              json.decode(response.body) as Map<String, dynamic>;
          numero = extractedData['data'].length + 1;
        }
      } catch (error) {
        throw error;
      }

      String numeroStringa = '0000$numero';
      codiceWO = 'TM.${numeroStringa.substring(numeroStringa.length - 5)}';

      task.code = codiceWO;

      final urlWo = Uri.parse('$urlAmbiente/api/entities/v1/wo');
      final urlEquipment = Uri.parse('$urlAmbiente/api/entities/v1/woeqpt');

      final dataWO = json.encode(
        task.commessa!.responsabile!.id == null
            ? {
                'data': {
                  'type': 'wo',
                  'attributes': {
                    'code': task.code,
                    'description': task.description,
                    'statusCode': task.statusCode,
                    'workPriority': task.priority,
                    'xtraTxt10': task.note,
                    'WOBegin':
                        "${task.dataInizio!.toIso8601String().substring(0, 23)}+01:00",
                    'WOEnd':
                        "${task.dataFine!.toIso8601String().substring(0, 23)}+01:00",
                    'expTime': (task.stima!.inMinutes / 60)
                  },
                  'relationships': {
                    "actionType": {
                      "data": {
                        "type": "actiontype",
                        "id": task.actionType!.id,
                      }
                    },
                  }
                }
              }
            : {
                'data': {
                  'type': 'wo',
                  'attributes': {
                    'code': task.code,
                    'description': task.description,
                    'statusCode': task.statusCode,
                    'workPriority': task.priority,
                    'xtraTxt10': task.note,
                    'WOBegin':
                        "${task.dataInizio!.toIso8601String().substring(0, 23)}+01:00",
                    'WOEnd':
                        "${task.dataFine!.toIso8601String().substring(0, 23)}+01:00",
                    'expTime': (task.stima!.inMinutes / 60)
                  },
                  'relationships': {
                    "actionType": {
                      "data": {
                        "type": "actiontype",
                        "id": task.actionType!.id,
                      }
                    },
                    "supervisor": {
                      "data": {
                        "type": "actor",
                        "id": task.commessa!.responsabile!.id,
                      }
                    }
                  }
                }
              },
      );

      try {
        // Chiamata per creare il WO
        final response = await http.post(
          urlWo,
          body: dataWO,
          headers: headers,
        );
        logger.d(response.body);

        logger.d('Stato wo: ${json.decode(response.statusCode.toString())}');

        if (response.statusCode >= 400) {
          throw HttpException(
            json.decode(response.body)['errors'][0]['title'].toString(),
          );
        } else {
          task.id = json.decode(response.body)['data']['id'];
        }
      } catch (error) {
        //logger.d(error);
        throw error;
      }

      // Json per il cliente
      final dataBox = json.encode(
        {
          "data": {
            "type": "woeqpt",
            "attributes": {
              "UOwner": null,
              "modifyDate": null,
              "directEqpt": true,
              "persoId": null,
              "referEqpt": false
            },
            "relationships": {
              "WO": {
                "data": {"type": "wo", "id": task.id}
              },
              "eqpt": {
                "data": {"type": "box", "id": task.cliente!.id}
              }
            }
          }
        },
      );

      // Json per la commessa
      final dataMaterial = json.encode(
        {
          "data": {
            "type": "woeqpt",
            "attributes": {
              "UOwner": null,
              "modifyDate": null,
              "directEqpt": true,
              "persoId": null,
              "referEqpt": true
            },
            "relationships": {
              "WO": {
                "data": {"type": "wo", "id": task.id}
              },
              "eqpt": {
                "data": {"type": "material", "id": task.commessa!.id}
              }
            }
          }
        },
      );

      if (task.cliente!.id != null) {
        try {
          // Chiamata per creare il legame con WO-cliente
          final responseBox = await http.post(
            urlEquipment,
            body: dataBox,
            headers: headers,
          );

          logger.d('Stato box: ${responseBox.statusCode}');

          if (responseBox.statusCode >= 400) {
            throw HttpException(
              json.decode(responseBox.body)['errors'][0]['title'].toString(),
            );
          }
        } catch (error) {
          logger.d(error);
          throw error;
        }
      }

      if (task.commessa!.id != null) {
        try {
          // Chiamata per creare il legame con WO-commessa
          final responseMaterial = await http.post(
            urlEquipment,
            body: dataMaterial,
            headers: headers,
          );

          logger.d('Stato material: ${responseMaterial.statusCode}');

          if (responseMaterial.statusCode >= 400) {
            throw HttpException(
              json
                  .decode(responseMaterial.body)['errors'][0]['title']
                  .toString(),
            );
          }
        } catch (error) {
          logger.d(error);
          throw error;
        }
      }

      final newTask = Task(
        code: task.code,
        description: task.description,
        statusCode: task.statusCode,
        priority: task.priority,
        actionType: task.actionType,
        note: task.note,
        cliente: task.cliente,
        commessa: task.commessa,
        dataInizio: task.dataInizio,
        dataFine: task.dataFine,
        id: task.id,
      );

      _tasks.insert(index, newTask);
      notifyListeners();
    } catch (error) {
      //logger.d(error);
      throw error;
    }
  }

  Future<void> updateTask(String id, Task initTask, Task newTask) async {
    final woIndex = _tasks.indexWhere((wo) => wo.id == id);

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final urlWo = Uri.parse('$urlAmbiente/api/entities/v1/wo/$id');
    final urlEquipment = Uri.parse('$urlAmbiente/api/entities/v1/woeqpt');

    final dataWO = json.encode(
      {
        'data': {
          'type': 'wo',
          'attributes': {
            'code': newTask.code,
            'description': newTask.description,
            'statusCode': newTask.statusCode,
            'workPriority': newTask.priority,
            'xtraTxt10': newTask.note,
            'WOBegin':
                "${newTask.dataInizio!.toIso8601String().substring(0, 23)}+01:00",
            'WOEnd':
                "${newTask.dataFine!.toIso8601String().substring(0, 23)}+01:00",
            'expTime': (newTask.stima!.inMinutes / 60)
          },
          'relationships': {
            "actionType": {
              "data": {
                "type": "actiontype",
                "id": newTask.actionType!.id,
              }
            },
          }
        }
      },
    );

    final dataBox = json.encode(
      {
        "data": {
          "type": "woeqpt",
          "attributes": {
            "UOwner": null,
            "modifyDate": null,
            "directEqpt": true,
            "persoId": null,
            "referEqpt": false
          },
          "relationships": {
            "WO": {
              "data": {"type": "wo", "id": newTask.id}
            },
            "eqpt": {
              "data": {"type": "box", "id": newTask.cliente!.id}
            }
          }
        }
      },
    );

    if (woIndex >= 0) {
      try {
        final response = await http.patch(
          urlWo,
          body: dataWO,
          headers: headers,
        );

        logger.d('Stato update wo: ${response.statusCode}');

        if (response.statusCode >= 400) {
          throw HttpException(
            json.decode(response.body)['errors'][0]['title'].toString(),
          );
        }

        // Se il nuovo WO ha un box non nullo
        if (newTask.cliente!.id != null) {
          // Se il nuovo WO ha un box non nullo e il WO precendente aveva già associato un box
          if (newTask.cliente!.id != null && initTask.cliente!.id != null) {
            final url =
                Uri.parse('$urlAmbiente/api/entities/v1/wo/$id/equipments');
            final responseWoEqpt = await http.get(
              url,
              headers: headers,
            );

            var woeqptData =
                json.decode(responseWoEqpt.body) as Map<String, dynamic>;

            var idWoEqpt;

            woeqptData['data'].forEach(
              (woeqpt) async {
                if (woeqpt['attributes']['directEqpt'] == true) {
                  idWoEqpt = woeqpt['id'];
                }
              },
            );

            final urlUpdateWoEqpt =
                Uri.parse('$urlAmbiente/api/entities/v1/woeqpt/$idWoEqpt');

            final responseEquipment = await http.patch(
              urlUpdateWoEqpt,
              body: dataBox,
              headers: headers,
            );

            logger.d('Stato box update: ${responseEquipment.statusCode}');

            if (response.statusCode >= 400) {
              throw HttpException(
                json
                    .decode(responseEquipment.body)['errors'][0]['title']
                    .toString(),
              );
            }
          }
          // Se il nuovo WO ha un box associato e il WO precedente non aveva un box associato
          if (newTask.cliente!.id != null && initTask.cliente!.id == null) {
            final responseEquipment = await http.post(
              urlEquipment,
              body: dataBox,
              headers: headers,
            );

            logger.d('Stato box insert: ${responseEquipment.statusCode}');

            if (response.statusCode >= 400) {
              throw HttpException(
                json
                    .decode(responseEquipment.body)['errors'][0]['title']
                    .toString(),
              );
            }
          }
        } else {
          final url =
              Uri.parse('$urlAmbiente/api/entities/v1/wo/$id/equipments');

          final responseWoEqpt = await http.get(
            url,
            headers: headers,
          );

          var woeqptData =
              json.decode(responseWoEqpt.body) as Map<String, dynamic>;

          if (response.statusCode >= 400) {
            throw HttpException(
              json.decode(responseWoEqpt.body)['errors'][0]['title'].toString(),
            );
          }

          woeqptData['data'].forEach(
            (woeqpt) async {
              if (woeqpt['attributes']['directEqpt'] == true) {
                var idWoEqpt = woeqpt['id'];

                final urlDeleteWoEqpt =
                    Uri.parse('$urlAmbiente/api/entities/v1/woeqpt/$idWoEqpt');

                final responseDeleteWoEqpt = await http.delete(
                  urlDeleteWoEqpt,
                  headers: headers,
                );
                logger.d('Stato delete: ${responseDeleteWoEqpt.statusCode}');

                if (response.statusCode >= 400) {
                  throw HttpException(
                    json
                        .decode(responseDeleteWoEqpt.body)['errors'][0]['title']
                        .toString(),
                  );
                }
              }
            },
          );
        }

        _tasks[woIndex] = newTask;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    } else {
      logger.d('...');
    }
  }

  Future<void> passaggioStatoTask(
      Task task, String statoNew, String statoOdl) async {
    logger.d('Funzione passaggioStatoTask');

    String? transizioneId;

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final url = Uri.parse(
        '$urlAmbiente/api/entities/v1/wo/${task.id}/workflow-transitions');

    if (statoNew == 'INPROGRESS' && statoOdl == 'AWAITINGREAL') {
      transizioneId =
          '18513f08e77-2075c:com.carl.xnet.system.status.TransitionParameters';
    }
    if (statoNew == 'INPROGRESS' && statoOdl == 'PAUSE') {
      transizioneId =
          '18513f08e77-20756:com.carl.xnet.system.status.TransitionParameters';
    }
    if (statoNew == 'PAUSE') {
      transizioneId =
          '18513f08e77-20762:com.carl.xnet.system.status.TransitionParameters';
    } else if (statoNew == 'CONCLUSIONE') {
      transizioneId =
          '18513f08e77-20763:com.carl.xnet.system.status.TransitionParameters';
    }

    final data = json.encode(
      {
        "data": {"id": transizioneId, "type": "workflow-transitions"}
      },
    );

    logger.d(data);

    try {
      // Chiamata per effettuare il passaggio di stato
      final response = await http.post(
        url,
        body: data,
        headers: headers,
      );

      logger.d(
          'Stato passaggio di stato: ${json.decode(response.statusCode.toString())}');

      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      }
      task.statusCode =
          json.decode(response.body)['data']['attributes']['nextStepCode'];

      notifyListeners();
    } catch (error) {
      logger.d(error);
      throw error;
    }
  }

  Future<void> updatePeriodTask(
      String id, Task task, DateTime dataOccupation) async {
    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    logger.d('task date: ${task.dataInizio}');
    logger.d('occupation date: ${dataOccupation}');

    final woIndex = _tasks.indexWhere((wo) => wo.id == id);

    final url = Uri.parse('$urlAmbiente/api/entities/v1/wo/$id');

    if (task.dataInizio!.isAfter(dataOccupation)) {
      task.dataInizio = DateTime(
        dataOccupation.year,
        dataOccupation.month,
        dataOccupation.day,
        8,
      );
    } else if (task.dataFine!.isBefore(dataOccupation)) {
      task.dataFine = DateTime(
        dataOccupation.year,
        dataOccupation.month,
        dataOccupation.day,
        18,
      );
    }

    final data = json.encode(
      {
        'data': {
          'type': 'wo',
          'attributes': {
            'WOBegin':
                "${task.dataInizio!.toIso8601String().substring(0, 23)}+01:00",
            'WOEnd':
                "${task.dataFine!.toIso8601String().substring(0, 23)}+01:00",
            'expTime': (task.stima!.inMinutes / 60)
          },
        }
      },
    );

    try {
      final response = await http.patch(
        url,
        body: data,
        headers: headers,
      );

      logger.d('Stato update wo: ${response.statusCode}');

      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      }

      if (woIndex >= 0) {
        _tasks[woIndex] = task;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }
}
