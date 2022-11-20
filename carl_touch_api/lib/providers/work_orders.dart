import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/work_order.dart';
import '../providers/actiontype.dart';
import '../providers/box.dart';

class WorkOrders with ChangeNotifier {
  final String authToken;
  final String userId;
  final String urlAmbiente;

  List<WorkOrder> _workOrders = [];

  WorkOrders(this.urlAmbiente, this.authToken, this.userId, this._workOrders);

  // Lista dei WO
  List<WorkOrder> get wo {
    return [..._workOrders];
  }

  // Recupera un WO per ID
  WorkOrder findById(String id) {
    return _workOrders.firstWhere((workOrder) => workOrder.id == id);
  }

  // Recupera il numero di WO
  int get itemCount {
    return _workOrders.length;
  }

  // Metodo per estrarre i WO tramite richiesta http
  Future<void> fetchAndSetWorkOrders([bool filterByUser = false]) async {
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
    };
    var url = Uri.parse(
        '$urlAmbiente/api/entities/v1/wo?fields=id,code,description,statusCode,actionType,assignedTo,equipments&filter[statusCode]=INPROGRESS');

    try {
      var response = await http.get(
        url,
        headers: headers,
      );
      var extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<WorkOrder> loadedWorkOrders = [];
      //print(json.decode(response.body));

      // Se non sono presenti WO esco dalla funzione
      if (extractedData['data'] == null) {
        return;
      }

      extractedData['data'].forEach(
        (wo) async {
          // Per estrarre la natura da ogni WO lancio una chiamata per ognuno
          // print(wo['relationships']['actionType']['links']['related']
          //     .toString());
          var actionTypeUrl = Uri.parse(
              wo['relationships']['actionType']['links']['related'].toString());
          try {
            var actionTypeResponse = await http.get(
              actionTypeUrl,
              headers: headers,
            );

            var actionTypeData =
                json.decode(actionTypeResponse.body) as dynamic;
            // print(json.decode(actionType_response.body));
            var actiontype = ActionType(
              id: actionTypeData['data']['id'],
              code: actionTypeData['data']['attributes']['code'],
              description: actionTypeData['data']['attributes']['description'],
            );

            var woeqptUrl = Uri.parse(wo['relationships']['equipments']['links']
                    ['related']
                .toString());

            var woeqptResponse = await http.get(
              woeqptUrl,
              headers: headers,
            );

            var woeqptData =
                json.decode(woeqptResponse.body) as Map<String, dynamic>;

            var boxLocation = Box(
              id: null,
              code: '',
              description: '',
              eqptType: '',
              statusCode: '',
            );

            //print(woeqptData);

            woeqptData['data'].forEach(
              (woeqpt) async {
                //print(woeqpt['attributes']['directEqpt']);
                if (woeqpt['attributes']['directEqpt'] == true) {
                  var boxLocationUrl = Uri.parse(woeqpt['relationships']['eqpt']
                          ['links']['related']
                      .toString());
                  //print(woeqpt['relationships']['eqpt']['links']['related']);

                  var boxLocationResponse = await http.get(
                    boxLocationUrl,
                    headers: headers,
                  );
                  var boxLocationdData = json.decode(boxLocationResponse.body)
                      as Map<String, dynamic>;

                  boxLocation.id = boxLocationdData['data']['attributes']['id'];
                  boxLocation.code =
                      boxLocationdData['data']['attributes']['code'];
                  boxLocation.description =
                      boxLocationdData['data']['attributes']['description'];
                  boxLocation.eqptType =
                      boxLocationdData['data']['attributes']['eqptType'];
                  boxLocation.statusCode =
                      boxLocationdData['data']['attributes']['statusCode'];
                  // boxLocation = Box(
                  //   id: boxLocationdData['data']['id'],
                  //   code: boxLocationdData['data']['attributes']['code'],
                  //   description: boxLocationdData['data']['attributes']
                  //       ['description'],
                  //   eqptType: boxLocationdData['data']['attributes']
                  //       ['eqptType'],
                  //   statusCode: boxLocationdData['data']['attributes']
                  //       ['statusCode'],
                  // );
                  //print(boxLocation.code);
                }
              },
            );

            loadedWorkOrders.add(
              WorkOrder(
                id: wo['id'],
                codice: wo['attributes']['code'],
                descrizione: wo['attributes']['description'],
                statusCode: wo['attributes']['statusCode'],
                actionType: actiontype,
                box: boxLocation,
              ),
            );
            // print(wo['attributes']['code']);
            _workOrders = loadedWorkOrders;
            notifyListeners();
          } catch (error) {
            throw error;
          }
        },
      );
    } catch (error) {
      //print(error.toString());
      throw error;
    }
  }

  Future<void> addWorkOrder(WorkOrder workOrder, {int index = 0}) async {
    //print('Box: ${workOrder.box.id}');
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
            'code': workOrder.codice,
            'description': workOrder.descrizione,
            'statusCode': workOrder.statusCode
          },
          'relationships': {
            "actionType": {
              "data": {
                "type": "actiontype",
                "id": workOrder.actionType.id,
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

      workOrder.id = json.decode(response.body)['data']['id'];

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
                "data": {"type": "wo", "id": workOrder.id}
              },
              "eqpt": {
                "data": {"type": "box", "id": workOrder.box.id}
              }
            }
          }
        },
      );

      if (workOrder.box.id != null) {
        final responseEquipment = await http.post(
          urlEquipment,
          body: dataBox,
          headers: headers,
        );

        print('Stato box: ${responseEquipment.statusCode}');
      }

      final newWorkOrder = WorkOrder(
        codice: workOrder.codice,
        descrizione: workOrder.descrizione,
        statusCode: workOrder.statusCode,
        actionType: workOrder.actionType,
        box: workOrder.box,
        id: json.decode(response.body)['data']['id'],
      );

      //print(json.decode(response.body)['data']['id']);

      _workOrders.insert(index, newWorkOrder);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateWorkOrder(
      String id, WorkOrder initWorkOrder, WorkOrder newWorkOrder) async {
    final woIndex = _workOrders.indexWhere((wo) => wo.id == id);

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
            'code': newWorkOrder.codice,
            'description': newWorkOrder.descrizione,
            'statusCode': newWorkOrder.statusCode
          },
          'relationships': {
            "actionType": {
              "data": {
                "type": "actiontype",
                "id": newWorkOrder.actionType.id,
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
              "data": {"type": "wo", "id": newWorkOrder.id}
            },
            "eqpt": {
              "data": {"type": "box", "id": newWorkOrder.box.id}
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

        if (newWorkOrder.box.id != null) {
          // Se il nuovo WO ha un box non nullo e il WO precendente aveva già associato un box
          if (newWorkOrder.box.id != null && initWorkOrder.box.id != null) {
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
          if (newWorkOrder.box.id != null && initWorkOrder.box.id == null) {
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

        _workOrders[woIndex] = newWorkOrder;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    } else {
      print('...');
    }
  }
}
