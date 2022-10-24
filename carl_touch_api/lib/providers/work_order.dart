import 'package:flutter/foundation.dart';

import '../providers/actiontype.dart';

class WorkOrder with ChangeNotifier {
  final String id;
  final String codice;
  final String descrizione;
  final ActionType actionType;

  final String statusCode;

  WorkOrder({
    @required this.id,
    @required this.codice,
    @required this.descrizione,
    @required this.actionType,
    @required this.statusCode,
  });
}
