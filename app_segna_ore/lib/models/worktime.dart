import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'material.dart' as carl;
import 'task.dart';
import 'actor.dart';

class WorkTime with ChangeNotifier {
  String? id;
  DateTime data;
  Actor? attore;
  Task? task;
  carl.Material commessa;
  Duration tempoFatturato;
  String note;

  WorkTime({
    required this.id,
    required this.data,
    this.attore,
    this.task,
    required this.commessa,
    required this.tempoFatturato,
    required this.note,
  });
}
