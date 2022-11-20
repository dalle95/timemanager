import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/box.dart';

class Boxes with ChangeNotifier {
  final String authToken;
  final String urlAmbiente;

  List<Box> _boxes = [];

  Boxes(this.urlAmbiente, this.authToken, this._boxes);

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
        Uri.parse('$urlAmbiente/api/entities/v1/box?filter[code][LIKE]=TEST');

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
          _boxes = loadedBoxes;
          notifyListeners();
        },
      );
    } catch (error) {
      throw error;
    }
  }
}
