import 'dart:convert';
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
          ? '$urlAmbiente/api/entities/v1/occupation?fields=occupationDate,duration,note,&include=technician,commessa,WO&filter[technician.id]=$userId'
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

          // Controllo il WO collegato
          if (record['id'] == occupation['relationships']['WO']['data']['id']) {
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
              dataInizio: record['attributes']['WOBegin'],
              dataFine: record['attributes']['WOEnd'],
              note: record['attributes']['xtraTxt10'],
              workflowTransitions: [],
            );
          }
        }

        print('data: ${occupation['attributes']['occupationDate']}ù');

        // Aggiunta WorkTime alla lista
        loadedWorkTimes.add(
          WorkTime(
            id: occupation['id'],
            note: occupation['attributes']['note'] ?? '',
            data: DateTime.parse(occupation['attributes']['occupationDate']),
            tempoLavorato:
                parseDuration(occupation['attributes']['duration']) ??
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
