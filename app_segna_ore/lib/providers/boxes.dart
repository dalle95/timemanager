import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/box.dart';

class Boxes with ChangeNotifier {
  final String authToken;
  final String urlAmbiente;

  List<Box> _boxes = [];

  Boxes(this.urlAmbiente, this.authToken, this._boxes);

  // Per gestire i log
  var logger = Logger();

  List<Box> get boxes {
    return [..._boxes];
  }

  // Recupera un ActionType per ID
  Box findById(String id) {
    return _boxes.firstWhere((box) => box.id == id);
  }

  // Recupera un ActionType per ID
  Box findByCode(String code) {
    return _boxes.firstWhere((box) => box.code == code);
  }

  // Recupera il numero di ActionType
  int get itemCount {
    return _boxes.length;
  }

  // Funzione per estrarre le nature tramite richiesta get
  Future<void> fetchAndSetBoxes() async {
    final url =
        Uri.parse('$urlAmbiente/api/entities/v1/box?filter[eqptType]=CLIENTE');

    try {
      var response = await http.get(
        url,
        headers: {
          "X-CS-Access-Token": authToken,
        },
      );
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      final List<Box> loadedBoxes = [];

      if (extractedData['data'] == null) {
        return;
      }

      extractedData['data'].forEach(
        (box) {
          loadedBoxes.add(
            Box(
              id: box['id'],
              code: box['attributes']['code'],
              description: box['attributes']['description'],
              eqptType: box['attributes']['eqptType'],
              statusCode: box['attributes']['statusCode'],
            ),
          );
        },
      );
      // Ordino la lista in base al codice del WO
      loadedBoxes.sort((a, b) => a.code.compareTo(b.code));

      // Aggiorno la lista dei Box
      _boxes = loadedBoxes;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addBox(Box box, {int index = 0}) async {
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final url = Uri.parse('$urlAmbiente/api/entities/v1/box');

    final dataBox = json.encode(
      {
        'data': {
          "type": "box",
          "attributes": {
            "code": box.code,
            "description": box.description,
            "statusCode": box.statusCode,
            "eqptType": box.eqptType,
          },
          "relationships": {
            "structure": {
              "data": {"type": "structure", "id": "LOCATION"}
            }
          }
        },
      },
    );

    try {
      final response = await http.post(
        url,
        body: dataBox,
        headers: headers,
      );

      // Recupero l'ID del Box appena creato
      box.id = json.decode(response.body)['data']['id'];

      logger.d('Stato box: ${json.decode(response.statusCode.toString())}');

      // Aggiungo il Box appena creato alla lista
      _boxes.insert(index, box);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateBox(String id, Box initBox, Box newBox) async {
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    final boxIndex = _boxes.indexWhere((box) => box.id == id);

    final url = Uri.parse('$urlAmbiente/api/entities/v1/box/$id');

    final dataBox = json.encode(
      {
        'data': {
          "type": "box",
          "attributes": {
            "code": newBox.code,
            "description": newBox.description,
            "statusCode": newBox.statusCode,
            "eqptType": newBox.eqptType,
          },
          "relationships": {
            "structure": {
              "data": {"type": "structure", "id": "LOCATION"}
            }
          }
        },
      },
    );

    if (boxIndex >= 0) {
      try {
        final response = await http.patch(
          url,
          body: dataBox,
          headers: headers,
        );

        logger.d('Stato box: ${response.statusCode}');

        // Aggiorno il Box nella lista
        _boxes[boxIndex] = newBox;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }
}
