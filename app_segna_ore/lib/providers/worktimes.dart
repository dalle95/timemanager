import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/worktime.dart';
import '../providers/task.dart';
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
    return _workTimes.firstWhere((WorkTime) => WorkTime.id == id);
  }

  // Recupera il numero di WO
  int get itemCount {
    return _workTimes.length;
  }

  // Funzione per estrarre le nature tramite richiesta get
  Future<void> fetchAndSetWorkTimes() async {
    final url = Uri.parse(
        '$urlAmbiente/api/entities/v1/wo?fields=code,description,statusCode,actionType,createdBy,equipments&include=actionType,createdBy,equipments&filter[wo][actionType.code]=TEST');

    try {
      var response = await http.get(
        url,
        headers: {
          "X-CS-Access-Token": authToken,
        },
      );
      var extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<WorkTime> loadedWorkTimes = [];

      if (extractedData['data'] == null) {
        return;
      }

      extractedData['data'].forEach(
        (workTime) {
          var wo_ID = workTime['relationships']['WO']['data'];
          if (wo_ID != null) {
            wo_ID = workTime['relationships']['WO']['data']['id'];
          }

          loadedWorkTimes.add(
            WorkTime(
              id: workTime['id'],
              code: workTime['code'],
              task: Task(
                id: wo_ID,
              ),
              commessa: carl.Material(
                id: null,
              ),
              // note: workTime['note'],
              // tempoLavorato: workTime['tempoLavorato'],
              // tempoFatturato: workTime['tempoFatturato'],
              // addebitoTrasferta: workTime['addebitoTrasferta'],
              // distanzaSede: workTime['distanzaSede'],
              // spesePasto: workTime['spesePasto'],
              // speseNotte: workTime['speseNotte'],
              // speseAltro: workTime['speseAltro'],
              // comune: workTime['comune'],
            ),
          );
        },
      );

      // Ordino la lista in base alla data
      loadedWorkTimes.sort(
        (a, b) => a.code.compareTo(b.code),
      );

      // Aggiorno la lista dei Box
      _workTimes = loadedWorkTimes;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Future<void> addWorkTime(WorkTime WorkTime, {int index = 0}) async {
  //   // Preparo l'header
  //   Map<String, String> headers = {
  //     "X-CS-Access-Token": authToken,
  //     "Content-Type": "application/vnd.api+json",
  //   };

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

  //     _workOrders.insert(index, newWorkOrder);
  //     notifyListeners();
  //   } catch (error) {
  //     print(error);
  //     throw error;
  //   }
  // }
}
