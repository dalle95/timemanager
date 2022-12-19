import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/material.dart';

class Materials with ChangeNotifier {
  final String authToken;
  final String urlAmbiente;

  List<Material> _materials = [];

  Materials(this.urlAmbiente, this.authToken, this._materials);

  List<Material> get materials {
    return [..._materials];
  }

  // Recupera un ActionType per ID
  Material findById(String id) {
    return _materials.firstWhere((material) => material.id == id);
  }

  // Recupera un ActionType per ID
  Material findByCode(String code) {
    return _materials.firstWhere((material) => material.code == code);
  }

  // Recupera il numero di ActionType
  int get itemCount {
    return _materials.length;
  }

  // Funzione per estrarre le nature tramite richiesta get
  Future<void> fetchAndSetMaterials() async {
    final url = Uri.parse(
      '$urlAmbiente/api/entities/v1/material?fields=code,description,statusCode,eqptType',
    );

    try {
      var response = await http.get(
        url,
        headers: {
          "X-CS-Access-Token": authToken,
        },
      );
      var extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Material> loadedMaterials = [];

      if (extractedData['data'] == null) {
        return;
      }

      extractedData['data'].forEach(
        (material) {
          loadedMaterials.add(
            Material(
              id: material['id'],
              code: material['attributes']['code'],
              description: material['attributes']['description'],
              eqptType: material['attributes']['eqptType'],
              statusCode: material['attributes']['statusCode'],
            ),
          );
        },
      );
      // Ordino la lista in base al codice del Material
      loadedMaterials.sort((a, b) => a.code.compareTo(b.code));

      // Aggiorno la lista dei Box
      _materials = loadedMaterials;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Future<void> addBox(Box box, {int index = 0}) async {
  //   Map<String, String> headers = {
  //     "X-CS-Access-Token": authToken,
  //     "Content-Type": "application/vnd.api+json",
  //   };

  //   final url = Uri.parse('$urlAmbiente/api/entities/v1/box');

  //   final dataBox = json.encode(
  //     {
  //       'data': {
  //         "type": "box",
  //         "attributes": {
  //           "code": box.code,
  //           "description": box.description,
  //           "statusCode": box.statusCode,
  //           "eqptType": box.eqptType,
  //         },
  //         "relationships": {
  //           "structure": {
  //             "data": {"type": "structure", "id": "LOCATION"}
  //           }
  //         }
  //       },
  //     },
  //   );

  //   try {
  //     final response = await http.post(
  //       url,
  //       body: dataBox,
  //       headers: headers,
  //     );

  //     // Recupero l'ID del Box appena creato
  //     box.id = json.decode(response.body)['data']['id'];

  //     print('Stato box: ${json.decode(response.statusCode.toString())}');

  //     // Aggiungo il Box appena creato alla lista
  //     _materials.insert(index, box);
  //     notifyListeners();
  //   } catch (error) {
  //     throw error;
  //   }
  // }

  // Future<void> updateBox(String id, Box initBox, Box newBox) async {
  //   Map<String, String> headers = {
  //     "X-CS-Access-Token": authToken,
  //     "Content-Type": "application/vnd.api+json",
  //   };

  //   final boxIndex = _materials.indexWhere((box) => box.id == id);

  //   final url = Uri.parse('$urlAmbiente/api/entities/v1/box/$id');

  //   final dataBox = json.encode(
  //     {
  //       'data': {
  //         "type": "box",
  //         "attributes": {
  //           "code": newBox.code,
  //           "description": newBox.description,
  //           "statusCode": newBox.statusCode,
  //           "eqptType": newBox.eqptType,
  //         },
  //         "relationships": {
  //           "structure": {
  //             "data": {"type": "structure", "id": "LOCATION"}
  //           }
  //         }
  //       },
  //     },
  //   );

  //   if (boxIndex >= 0) {
  //     try {
  //       final response = await http.patch(
  //         url,
  //         body: dataBox,
  //         headers: headers,
  //       );

  //       print('Stato box: ${response.statusCode}');

  //       // Aggiorno il Box nella lista
  //       _materials[boxIndex] = newBox;
  //       notifyListeners();
  //     } catch (error) {
  //       throw error;
  //     }
  //   }
  // }
}
