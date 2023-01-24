import 'dart:convert';

import 'package:app_segna_ore/providers/workflow_transitions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/task.dart';
import '../providers/actiontype.dart';
import '../providers/box.dart';
import '../providers/material.dart' as carl;

class Tasks with ChangeNotifier {
  final String authToken;
  final String userId;
  final String urlAmbiente;

  List<Task> _tasks = [];

  Tasks(this.urlAmbiente, this.authToken, this.userId, this._tasks);

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
      //extractedData['data'].forEach(
      //(wo) async {
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

          // Per estrazione della natura controllo l'uguaglianza dell'ID con quello nell'include
          // for (var
          // wo in extractedData['included']) {
          // if (actiontype['id'] ==
          //     wo['relationships']['actionType']['data']['id']) {
          // Definizione natura

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
            id: actionTypeData['id'],
            code: actionTypeData['data']['attributes']['code'],
            description: actionTypeData['data']['attributes']['description'],
          );

          // break;
          // }
          // }

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

            print(woEqptUrl);

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

            // Definizione url worktransition
            // var workfloTransitionsUrl =
            //     Uri.parse(wo['links']['workflow-transitions'].toString());
            // try {
            //   // Creazione chiamata worktransition
            //   var workfloTransitionResponse = await http.get(
            //     workfloTransitionsUrl,
            //     headers: headers,
            //   );
            //   // Estrazione risultati
            //   var workfloTransitionData =
            //       json.decode(workfloTransitionResponse.body) as dynamic;
            //   // Iterazione per ogni risulato
            //   workfloTransitionData['data'].forEach(
            //     (wt) {
            //       // Definizione worktransition
            //       var workflowTransition = WorkflowTransitions(
            //         id: wt['id'],
            //         statusCode: wt['attributes']['nextStepCode'],
            //       );
            //       // Aggiunta transizioni alla lista workflowtransitions
            //       listWorkflowTransitions.add(workflowTransition);
            //     },
            //   );
            // } catch (error) {
            //   throw error;
            // }

            print(
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
                    minutes: (wo['attributes']['expTime'] * 60).toInt()),
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
      print(error.toString());
      throw error;
    } finally {
      // Aggiornamento lista
      _tasks = loadedTasks;
      notifyListeners();
    }

    DateTime end = DateTime.now();
    print(end.difference(init).inMilliseconds);
  }

  Future<void> addTask(Task task, {int index = 0}) async {
    print('Funzione addTask');

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final urlWo = Uri.parse('$urlAmbiente/api/entities/v1/wo');
    final urlEquipment = Uri.parse('$urlAmbiente/api/entities/v1/woeqpt');

    final dataWO = json.encode(
      {
        'data': {
          'type': 'wo',
          'attributes': {
            'code': task.code,
            'description': task.description,
            'statusCode': task.statusCode,
            'workPriority': task.priority,
            'xtraTxt10': task.note,
            'WOBegin':
                task.dataInizio.toIso8601String().substring(0, 23) + "+01:00",
            'WOEnd':
                task.dataFine.toIso8601String().substring(0, 23) + "+01:00",
            'expTime': (task.stima.inMinutes / 60)
          },
          'relationships': {
            "actionType": {
              "data": {
                "type": "actiontype",
                "id": task.actionType.id,
              }
            },
            // "costCenter": {
            //   "data": {
            //     "type": "costcenter",
            //     "id": "177fed5ef2f-2ab4",
            //   }
            // }
          }
        }
      },
    );

    print(dataWO);

    //print(url);
    try {
      // Chiamata per creare il WO
      final response = await http.post(
        urlWo,
        body: dataWO,
        headers: headers,
      );
      print(response.body);

      task.id = json.decode(response.body)['data']['id'];

      print('Stato wo: ${json.decode(response.statusCode.toString())}');

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
                "data": {"type": "box", "id": task.cliente.id}
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
                "data": {"type": "material", "id": task.commessa.id}
              }
            }
          }
        },
      );

      if (task.cliente.id != null) {
        // Chiamata per creare il legame con WO-cliente
        final responseBox = await http.post(
          urlEquipment,
          body: dataBox,
          headers: headers,
        );

        print('Stato box: ${responseBox.statusCode}');
      }

      if (task.commessa.id != null) {
        // Chiamata per creare il legame con WO-commessa
        final responseMaterial = await http.post(
          urlEquipment,
          body: dataMaterial,
          headers: headers,
        );

        print('Stato material: ${responseMaterial.statusCode}');
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
        id: json.decode(response.body)['data']['id'],
      );

      //print(json.decode(response.body)['data']['id']);

      _tasks.insert(index, newTask);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateTask(String id, Task initTask, Task newTask) async {
    final woIndex = _tasks.indexWhere((wo) => wo.id == id);

    final urlWo = Uri.parse('$urlAmbiente/api/entities/v1/wo/$id');
    final urlEquipment = Uri.parse('$urlAmbiente/api/entities/v1/woeqpt');

    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final dataWO = json.encode(
      {
        'data': {
          'type': 'wo',
          'attributes': {
            'code': newTask.code,
            'description': newTask.description,
            'statusCode': newTask.statusCode
          },
          'relationships': {
            "actionType": {
              "data": {
                "type": "actiontype",
                "id": newTask.actionType.id,
              }
            },
            // "costCenter": {
            //   "data": {
            //     "type": "costcenter",
            //     "id": "177fed5ef2f-2ab4",
            //   }
            // }
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
              "data": {"type": "box", "id": newTask.cliente.id}
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

        print('Stato wo: ${response.statusCode}');

        // Se il nuovo WO ha un box non nullo
        if (newTask.cliente.id != null) {
          // Se il nuovo WO ha un box non nullo e il WO precendente aveva già associato un box
          if (newTask.cliente.id != null && initTask.cliente.id != null) {
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

            print('Stato box update: ${responseEquipment.statusCode}');
          }
          // Se il nuovo WO ha un box associato e il WO precedente non aveva un box associato
          if (newTask.cliente.id != null && initTask.cliente.id == null) {
            final responseEquipment = await http.post(
              urlEquipment,
              body: dataBox,
              headers: headers,
            );

            print('Stato box insert: ${responseEquipment.statusCode}');
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
          //print(woeqptData);

          woeqptData['data'].forEach(
            (woeqpt) async {
              if (woeqpt['attributes']['directEqpt'] == true) {
                var idWoEqpt = woeqpt['id'];

                final urlDeleteWoEqpt =
                    Uri.parse('$urlAmbiente/api/entities/v1/woeqpt/$idWoEqpt');
                //print(urlDeleteWoEqpt);

                final responseDeleteWoEqpt = await http.delete(
                  urlDeleteWoEqpt,
                  headers: headers,
                );
                print('Stato delete: ${responseDeleteWoEqpt.statusCode}');
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
      print('...');
    }
  }
}
