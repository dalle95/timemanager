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
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
    };
    var url = Uri.parse(
        '$urlAmbiente/api/entities/v1/wo?fields=code,description,statusCode,actionType,createdBy,equipments&include=actionType,createdBy,equipments&filter[wo][actionType.code]=BUG');

    try {
      var response = await http.get(
        url,
        headers: headers,
      );
      var extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Task> loadedTasks = [];

      // Se non sono presenti WO esco dalla funzione
      if (extractedData['data'] == null) {
        return;
      }

      // itero per ogni WO
      extractedData['data'].forEach(
        (wo) async {
          var actionType = ActionType(
            id: null,
            code: null,
            description: null,
          );
          // Per estrarre la natura controllo l'uguaglianza dell'ID con quello nell'include
          for (var actiontype in extractedData['included']) {
            if (actiontype['id'] ==
                wo['relationships']['actionType']['data']['id']) {
              // Inizializzazione natura
              actionType = ActionType(
                id: actiontype['id'],
                code: actiontype['attributes']['code'],
                description: actiontype['attributes']['description'],
              );
            }
          }

          // Inizializzo il BOX  e material vuoto
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
          // var woeqptUrl = Uri.parse(
          //     wo['relationships']['equipments']['links']['related'].toString());

          // var woeqptResponse = await http.get(
          //   woeqptUrl,
          //   headers: headers,
          // );

          // var woeqptData =
          //     json.decode(woeqptResponse.body) as Map<String, dynamic>;

          try {
            // Recupero il Box associato al WO
            for (var woeqpt in extractedData['included']) {
              // Controllo che il box sia collegato direttamente al WO
              if (woeqpt['attributes']['directEqpt'] == true ||
                  woeqpt['attributes']['referEqpt'] == true) {
                if (woeqpt['attributes']['directEqpt'] == true &&
                    woeqpt['attributes']['referEqpt'] == false) {
                  var boxLocationUrl = Uri.parse(woeqpt['relationships']['eqpt']
                          ['links']['related']
                      .toString());

                  var boxLocationResponse = await http.get(
                    boxLocationUrl,
                    headers: headers,
                  );
                  var boxLocationdData = json.decode(boxLocationResponse.body)
                      as Map<String, dynamic>;

                  // Definisco il BOX associato al WO
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
                // print(boxLocation.code);
              }
              if (woeqpt['attributes']['referEqpt'] == true) {
                var materialUrl = Uri.parse(woeqpt['relationships']['eqpt']
                        ['links']['related']
                    .toString());

                var materialResponse = await http.get(
                  materialUrl,
                  headers: headers,
                );
                var materialData =
                    json.decode(materialResponse.body) as Map<String, dynamic>;

                // Definisco il BOX associato al WO
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

            // Per estrarre le transizioni di stato da ogni WO lancio una chiamata per ognuno
            var workfloTransitionsUrl =
                Uri.parse(wo['links']['workflow-transitions'].toString());
            try {
              var workfloTransitionResponse = await http.get(
                workfloTransitionsUrl,
                headers: headers,
              );

              var workfloTransitionData =
                  json.decode(workfloTransitionResponse.body) as dynamic;

              workfloTransitionData['data'].forEach(
                (wt) {
                  var workflowTransition = WorkflowTransitions(
                    id: wt['id'],
                    statusCode: wt['attributes']['nextStepCode'],
                  );

                  listWorkflowTransitions.add(workflowTransition);
                },
              );
            } catch (error) {
              throw error;
            }

            print(
                'wo_code: ${wo['attributes']['code']}, actiontype_code: ${actionType.code}, box_code: ${boxLocation.code}');

            loadedTasks.add(
              Task(
                id: wo['id'],
                code: wo['attributes']['code'],
                description: wo['attributes']['description'] ?? '',
                statusCode: wo['attributes']['statusCode'],
                actionType: actionType,
                cliente: boxLocation,
                commessa: material,
                workflowTransitions: listWorkflowTransitions,
              ),
            );
          } catch (error) {
            throw error;
          } finally {
            // Ordino la lista in base al codice del WO
            loadedTasks.sort((a, b) => a.code.compareTo(b.code));

            // Aggiorno la lista di WO
            _tasks = loadedTasks;
          }
        },
      );

      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    } finally {}
  }

  Future<void> addTask(Task task, {int index = 0}) async {
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
            'statusCode': task.statusCode
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

    //print(url);
    try {
      final response = await http.post(
        urlWo,
        body: dataWO,
        headers: headers,
      );

      task.id = json.decode(response.body)['data']['id'];

      print('Stato wo: ${json.decode(response.statusCode.toString())}');

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

      if (task.cliente.id != null) {
        final responseEquipment = await http.post(
          urlEquipment,
          body: dataBox,
          headers: headers,
        );

        print('Stato box: ${responseEquipment.statusCode}');
      }

      final newTask = Task(
        code: task.code,
        description: task.description,
        statusCode: task.statusCode,
        actionType: task.actionType,
        cliente: task.cliente,
        commessa: task.commessa,
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
