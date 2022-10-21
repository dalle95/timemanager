import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/work_order.dart';

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
    var url = Uri.parse(
        '$urlAmbiente/api/entities/v1/wo?fields=id,code,description,statusCode,actionType,assignedTo&filter[statusCode]=REQUEST');

    try {
      var response = await http.get(
        url,
        headers: {
          "X-CS-Access-Token": authToken,
        },
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
          var actionType_url = Uri.parse(
              wo['relationships']['actionType']['links']['related'].toString());
          try {
            var actionType_response = await http.get(
              actionType_url,
              headers: {
                "X-CS-Access-Token": authToken,
              },
            );

            var actionTypeData =
                json.decode(actionType_response.body) as dynamic;
            // print(json.decode(actionType_response.body));
            var actionType_id = actionTypeData['data']['id'];
            var actionType_code = actionTypeData['data']['attributes']['code'];

            // print('${wo['attributes']['code']}: $actionType_code');
            loadedWorkOrders.add(
              WorkOrder(
                id: wo['id'],
                codice: wo['attributes']['code'],
                descrizione: wo['attributes']['description'],
                statusCode: wo['attributes']['statusCode'],
                actionType: {
                  'id': actionType_id,
                  'code': actionType_code,
                },
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
    final url = Uri.parse('$urlAmbiente/api/entities/v1/wo');
    //print(url);
    try {
      final response = await http.post(
        url,
        body: json.encode(
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
                    "id": workOrder.actionType['id'],
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
        ),
        headers: {
          "X-CS-Access-Token": authToken,
          "Content-Type": "application/vnd.api+json",
        },
      );

      if (response.statusCode >= 400) {
        print('Errore ${response.statusCode}');
      }

      print(json.decode(response.body));

      final newWorkOrder = WorkOrder(
        codice: workOrder.codice,
        descrizione: workOrder.descrizione,
        statusCode: workOrder.statusCode,
        actionType: {
          'id': workOrder.actionType['id'],
          'code': workOrder.actionType['code'],
        },
        id: json.decode(response.body)['data']['id'],
      );

      _workOrders.insert(index, newWorkOrder);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateWorkOrder(String id, WorkOrder newWorkOrder) async {
    final woIndex = _workOrders.indexWhere((wo) => wo.id == id);
    if (woIndex >= 0) {
      try {
        final url = Uri.parse('$urlAmbiente/api/entities/v1/wo/$id');
        final response = await http.patch(
          url,
          body: json.encode(
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
                      "id": newWorkOrder.actionType['id'],
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
          ),
          headers: {
            "X-CS-Access-Token": authToken,
            "Content-Type": "application/vnd.api+json",
          },
        );
        print(json.decode(response.body));
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
