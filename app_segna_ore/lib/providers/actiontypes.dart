import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/actiontype.dart';

class ActionTypes with ChangeNotifier {
  final String authToken;
  final String urlAmbiente;

  List<ActionType> _actiontypes = [];

  ActionTypes(this.urlAmbiente, this.authToken, this._actiontypes);

  // Definisco il metodo per recuerare la lista di nature
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
    // Inizializzo la lista di nature
    final List<ActionType> loadedActionTypes = [];

    // Chiamata get per estrazione delle nature
    try {
      final url = Uri.parse(
          '$urlAmbiente/api/entities/v1/actiontype?filter[actionGroup]=PREV');
      var response = await http.get(
        url,
        headers: {
          "X-CS-Access-Token": authToken,
        },
      );
      // Estraggo i dati
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

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
        },
      );
    } catch (error) {
      rethrow;
    } finally {
      _actiontypes = loadedActionTypes;
      notifyListeners();
    }
  }
}
