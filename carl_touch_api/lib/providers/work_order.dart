import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WorkOrder with ChangeNotifier {
  final String id;
  final String codice;
  final String descrizione;
  final String actionType;
  final String statusCode;

  WorkOrder({
    @required this.id,
    @required this.codice,
    @required this.descrizione,
    @required this.actionType,
    @required this.statusCode,
  });
}
