import 'package:app_segna_ore/providers/actor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/material.dart' as carl;
import '../providers/task.dart';

class WorkTime with ChangeNotifier {
  String id;
  DateTime data;
  Actor attore;
  Task task;
  carl.Material commessa;
  Duration tempoFatturato;
  String note;

  WorkTime({
    @required this.id,
    @required this.data,
    this.attore,
    @required this.task,
    @required this.commessa,
    @required this.tempoFatturato,
    @required this.note,
  });
}
