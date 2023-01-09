import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/material.dart' as carl;
import '../providers/task.dart';

class WorkTime with ChangeNotifier {
  String id;
  String code;
  DateTime data;
  Task task;
  carl.Material commessa;
  Duration tempoLavorato;
  Duration tempoFatturato;
  String note;
  bool addebitoTrasferta;
  int distanzaSede;
  double spesePasto;
  double speseNotte;
  double speseAltro;
  String comune;

  WorkTime({
    @required this.id,
    @required this.code,
    @required this.data,
    @required this.task,
    @required this.commessa,
    @required this.tempoLavorato,
    @required this.tempoFatturato,
    @required this.note,
    @required this.addebitoTrasferta,
    @required this.distanzaSede,
    @required this.spesePasto,
    @required this.speseNotte,
    @required this.speseAltro,
    @required this.comune,
  });
}
