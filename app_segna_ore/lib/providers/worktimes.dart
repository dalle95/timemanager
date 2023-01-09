import 'dart:convert';
import 'dart:ffi';
import 'package:app_segna_ore/providers/actiontype.dart';
import 'package:app_segna_ore/providers/box.dart';
import 'package:app_segna_ore/providers/task.dart';
import 'package:app_segna_ore/providers/workflow_transitions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/worktime.dart';
import '../providers/material.dart' as carl;

class WorkTimes with ChangeNotifier {
  final String authToken;
  final String userId;
  final String urlAmbiente;

  List<WorkTime> _workTimes = [];

  WorkTimes(this.urlAmbiente, this.authToken, this.userId, this._workTimes);

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
        oreSegnate = oreSegnate + _workTimes[index].tempoLavorato.inHours;
      }
    }
    return oreSegnate;
  }

  // Funzione per estrarre le nature tramite richiesta get
  Future<void> fetchAndSetWorkTimes([String periodoRiferimento]) async {
    // Inizializzazione lista vuota
    final List<WorkTime> loadedWorkTimes = [];

    // Definizione dell'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
    };

    // Funzione per convertire una stringa in una durata
    Duration parseDuration(String s) {
      int hours = 0;
      int minutes = 0;
      int micros;
      List<String> parts = s.split(':');
      if (parts.length > 2) {
        hours = int.parse(parts[parts.length - 3]);
      }
      if (parts.length > 1) {
        minutes = int.parse(parts[parts.length - 2]);
      }
      micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
      return Duration(hours: hours, minutes: minutes, microseconds: micros);
    }

    // Definizione del link della chiamata
    var url = Uri.parse(
      periodoRiferimento == null
          ? '$urlAmbiente/api/entities/v1/wo?fields=code,description,statusCode,WOBegin,WOEnd,workPriority,time01,time02,actionType,createdBy,equipments&include=actionType,createdBy,equipments&filter[wo][actionType.code]=TEST_SCRIPT&filter[wo][createdBy.id]=$userId'
          : '$urlAmbiente/api/entities/v1/wo?fields=code,description,statusCode,WOBegin,WOEnd,workPriority,time01,time02,actionType,createdBy,equipments&include=actionType,createdBy,equipments&filter[wo][actionType.code]=TEST_SCRIPT&filter[wo][createdBy.id]=$userId&filter[xtraTxt01]=$periodoRiferimento',
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

      // Iterazione per ogni risultato
      // extractedData['data'].forEach(
      //   (wo) async {
      for (var wo in extractedData['data']) {
        // Inizializzazione natura nulla
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

        // Inizializzo il BOX  e material nullo
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

        // Recupero del Box associato al WO
        for (var woeqpt in extractedData['included']) {
          // Controllo che il box sia collegato direttamente al WO
          if (woeqpt['attributes']['directEqpt'] == true ||
              woeqpt['attributes']['referEqpt'] == true) {
            if (woeqpt['attributes']['directEqpt'] == true &&
                woeqpt['attributes']['referEqpt'] == false) {
              // Definizione url per equipment
              var boxLocationUrl = Uri.parse(woeqpt['relationships']['eqpt']
                      ['links']['related']
                  .toString());
              // Creazione chiamata per estrazione box
              var boxLocationResponse = await http.get(
                boxLocationUrl,
                headers: headers,
              );
              // Estrazione risultati
              var boxLocationdData =
                  json.decode(boxLocationResponse.body) as Map<String, dynamic>;

              // Definizione del BOX associato
              boxLocation = Box(
                id: boxLocationdData['data']['id'],
                code: boxLocationdData['data']['attributes']['code'],
                description:
                    boxLocationdData['data']['attributes']['description'] ?? '',
                eqptType: boxLocationdData['data']['attributes']['eqptType'],
                statusCode: boxLocationdData['data']['attributes']
                    ['statusCode'],
              );
            }
          }
          // Controllo il material collegato
          if (woeqpt['attributes']['referEqpt'] == true) {
            // Definizione url material
            var materialUrl = Uri.parse(
                woeqpt['relationships']['eqpt']['links']['related'].toString());
            // Creazione chiamata material
            var materialResponse = await http.get(
              materialUrl,
              headers: headers,
            );
            // Estrazione risultati
            var materialData =
                json.decode(materialResponse.body) as Map<String, dynamic>;

            // Definizione Material associato
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

        // Inizializzazione lista di transizioni come lista vuota
        List<WorkflowTransitions> listWorkflowTransitions = [];

        // Per estrarre le transizioni di stato da ogni WO lancio una chiamata per ognuno
        // var workfloTransitionsUrl =
        //     Uri.parse(wo['links']['workflow-transitions'].toString());

        // var workfloTransitionResponse = await http.get(
        //   workfloTransitionsUrl,
        //   headers: headers,
        // );

        // var workfloTransitionData =
        //     json.decode(workfloTransitionResponse.body) as dynamic;

        // workfloTransitionData['data'].forEach(
        //   (wt) {
        //     var workflowTransition = WorkflowTransitions(
        //       id: wt['id'],
        //       statusCode: wt['attributes']['nextStepCode'],
        //     );

        //     listWorkflowTransitions.add(workflowTransition);
        //   },
        // );

        print(
            'wo_code: ${wo['attributes']['code']}, actiontype_code: ${actionType.code}, box_code: ${boxLocation.code}');

        // Aggiunta WorkTime alla lista
        loadedWorkTimes.add(
          WorkTime(
            id: wo['id'],
            code: wo['attributes']['code'],
            note: wo['attributes']['description'] ?? '',
            task: Task(
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
            ),
            data: DateTime.parse(wo['attributes']['WOBegin']),
            tempoLavorato: parseDuration(wo['attributes']['time01']) ??
                const Duration(
                  hours: 0,
                  minutes: 0,
                ),
            tempoFatturato: parseDuration(wo['attributes']['time02']) ??
                const Duration(
                  hours: 0,
                  minutes: 0,
                ),
            commessa: material,
          ),
        );

        // Ordino la lista in base al codice del WO
        loadedWorkTimes.sort((a, b) => a.data.compareTo(b.data));

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
    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    //   final url = Uri.parse('$urlAmbiente/api/entities/v1/WorkTime');

    //   final data = json.encode(
    //     {
    //       'data': {
    //         'type': 'WorkTime',
    //         'attributes': {
    //           'uowner': WorkTime.uowner,
    //           'WorkTimeDate': WorkTime.WorkTimeDate,
    //         },
    //         'relationships': {
    //           "WO": {
    //             "data": {
    //               "type": "wo",
    //               "id": WorkTime.wo.id,
    //             }
    //           },
    //           // "costCenter": {
    //           //   "data": {
    //           //     "type": "costcenter",
    //           //     "id": "177fed5ef2f-2ab4",
    //           //   }
    //           // }
    //         }
    //       }
    //     },
    //   );

    //   //print(url);
    //   try {
    //     final response = await http.post(
    //       urlWo,
    //       body: dataWO,
    //       headers: headers,
    //     );

    //     workOrder.id = json.decode(response.body)['data']['id'];

    //     print('Stato wo: ${json.decode(response.statusCode.toString())}');

    //     final dataBox = json.encode(
    //       {
    //         "data": {
    //           "type": "woeqpt",
    //           "attributes": {
    //             "UOwner": null,
    //             "modifyDate": null,
    //             "directEqpt": true,
    //             "persoId": null,
    //             "referEqpt": false
    //           },
    //           "relationships": {
    //             "WO": {
    //               "data": {"type": "wo", "id": workOrder.id}
    //             },
    //             "eqpt": {
    //               "data": {"type": "box", "id": workOrder.box.id}
    //             }
    //           }
    //         }
    //       },
    //     );

    //     if (workOrder.box.id != null) {
    //       final responseEquipment = await http.post(
    //         urlEquipment,
    //         body: dataBox,
    //         headers: headers,
    //       );

    //       print('Stato box: ${responseEquipment.statusCode}');
    //     }

    //     final newWorkOrder = WorkOrder(
    //       codice: workOrder.codice,
    //       descrizione: workOrder.descrizione,
    //       statusCode: workOrder.statusCode,
    //       actionType: workOrder.actionType,
    //       box: workOrder.box,
    //       id: json.decode(response.body)['data']['id'],
    //     );

    //     //print(json.decode(response.body)['data']['id']);

    workTimes.insert(index, workTime);
    notifyListeners();
    //   } catch (error) {
    //     print(error);
    //     throw error;
    //   }
  }
}
