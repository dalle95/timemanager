import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/actiontype.dart';

class ActionTypes with ChangeNotifier {
  final String authToken;
  final String urlAmbiente;

  List<ActionType> _actiontypes = [];

  ActionTypes(this.urlAmbiente, this.authToken, this._actiontypes);

  List<ActionType> get actionTypes {
    return [..._actiontypes];
  }

  // Recupera un ActionType per ID
  ActionType findById(String id) {
    return _actiontypes.firstWhere((actiontype) => actiontype.id == id);
  }

  // Recupera un ActionType per ID
  ActionType findByCode(String code) {
    return _actiontypes.firstWhere((actiontype) => actiontype.code == code);
  }

  // Recupera il numero di ActionType
  int get itemCount {
    return _actiontypes.length;
  }

  // Funzione per estrarre le nature tramite richiesta get
  Future<void> fetchAndSetActiontypes() async {
    final url = Uri.parse(
        '$urlAmbiente/api/entities/v1/actiontype?filter[actionGroup]=PREV');

    try {
      var response = await http.get(
        url,
        headers: {
          "X-CS-Access-Token": authToken,
        },
      );
      var extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<ActionType> loadedActionTypes = [];

      if (extractedData['data'] == null) {
        return;
      }

      extractedData['data'].forEach(
        (actiontype) {
          loadedActionTypes.add(
            ActionType(
              id: actiontype['id'],
              code: actiontype['attributes']['code'],
              description: actiontype['attributes']['description'],
            ),
          );
          _actiontypes = loadedActionTypes;
          notifyListeners();
        },
      );
    } catch (error) {
      throw error;
    }
  }
}
