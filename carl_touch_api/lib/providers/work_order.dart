import 'package:carl_touch_api/providers/box.dart';
import 'package:flutter/foundation.dart';

import '../providers/actiontype.dart';

class WorkOrder with ChangeNotifier {
  String id;
  String codice;
  String descrizione;
  String statusCode;
  ActionType actionType;
  Box box;

  WorkOrder({
    @required this.id,
    @required this.codice,
    @required this.descrizione,
    @required this.statusCode,
    @required this.actionType,
    this.box,
  });
}
