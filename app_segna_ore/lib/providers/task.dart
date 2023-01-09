import 'package:app_segna_ore/providers/box.dart';
import 'package:app_segna_ore/providers/material.dart';
import 'package:app_segna_ore/providers/workflow_transitions.dart';
import 'package:flutter/foundation.dart';

import '../providers/actiontype.dart';

class Task with ChangeNotifier {
  String id;
  String code;
  String description;
  String statusCode;
  String priority;
  ActionType actionType;
  Box cliente;
  Material commessa;
  DateTime dataInizio;
  DateTime dataFine;
  Duration stima;
  String note;
  List<WorkflowTransitions> workflowTransitions;

  Task({
    @required this.id,
    @required this.code,
    @required this.description,
    @required this.statusCode,
    @required this.priority,
    @required this.actionType,
    this.cliente,
    this.commessa,
    this.dataInizio,
    this.dataFine,
    this.stima,
    this.note,
    this.workflowTransitions,
  });
}
