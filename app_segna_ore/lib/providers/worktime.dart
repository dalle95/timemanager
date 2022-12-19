import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/material.dart' as carl;
import '../providers/task.dart';

class WorkTime with ChangeNotifier {
  String id;
  String code;
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
    this.task,
    @required this.commessa,
    @required this.tempoLavorato,
    @required this.tempoFatturato,
    @required this.note,
    this.addebitoTrasferta,
    this.distanzaSede,
    this.spesePasto,
    this.speseNotte,
    this.speseAltro,
    this.comune,
  });
}
