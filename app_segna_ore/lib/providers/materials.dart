import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/actor.dart';
import '../models/material.dart';

class Materials with ChangeNotifier {
  final String? authToken;
  final String? urlAmbiente;

  List<Material> _materials = [];

  Materials(this.urlAmbiente, this.authToken, this._materials);

  // Per gestire i log
  var logger = Logger();

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
  Future<void> fetchAndSetMaterials([String? cliente]) async {
    logger.d('Funzione fetchAndSetMaterials');
    final url = Uri.parse(
      cliente != null
          ? '$urlAmbiente/api/entities/v1/material?include=supervisor&filter[eqptType]=COMMESSA&filter[code][LIKE]=${cliente.toUpperCase()}'
          : '$urlAmbiente/api/entities/v1/material?include=supervisor&filter[eqptType]=COMMESSA',
    );

    try {
      var response = await http.get(
        url,
        headers: {
          "X-CS-Access-Token": authToken!,
        },
      );
      var extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Material> loadedMaterials = [];

      if (extractedData['data'] == null) {
        return;
      }

      // Definisco il responsabile nullo
      Actor responsabile = Actor(
        id: null,
        code: '',
        nome: '',
      );

      for (var material in extractedData['data']) {
        if (material['attributes']['statusCode'] == 'ATTESA_ORDINE' ||
            material['attributes']['statusCode'] == 'APERTA') {
          // Definisco il responsabile nullo
          responsabile = Actor(
            id: null,
            code: '',
            nome: '',
          );

          // Controllo che il supervisor non sia nullo
          if (material['relationships']['supervisor']['data'] != null) {
            // Recupero il supervisor associato al materiale
            for (var record in extractedData['included']) {
              // Controllo il supervisor collegato
              if (record['id'] ==
                  material['relationships']['supervisor']['data']['id']) {
                // Definizione Actor associato
                responsabile = Actor(
                    id: record['id'],
                    code: record['attributes']['code'],
                    nome: record['attributes']['fullName'] ?? '');
              }
            }
          }

          loadedMaterials.add(
            Material(
              id: material['id'],
              code: material['attributes']['code'],
              description: material['attributes']['description'],
              eqptType: material['attributes']['eqptType'],
              statusCode: material['attributes']['statusCode'],
              responsabile: responsabile,
            ),
          );
        }
      }

      // Ordino la lista in base al codice del Material
      loadedMaterials.sort((a, b) => a.code.compareTo(b.code));

      // Aggiorno la lista dei Box
      _materials = loadedMaterials;
      notifyListeners();
    } catch (error) {
      logger.d(error);
      throw error;
    }
  }
}
