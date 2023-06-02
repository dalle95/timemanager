import 'package:flutter/foundation.dart';

import 'actiontype.dart';
import 'box.dart';
import 'material.dart';
import 'workflow_transitions.dart';

class Task with ChangeNotifier {
  String? id;
  String code;
  String description;
  String statusCode;
  String? priority;
  ActionType? actionType;
  Box? cliente;
  Material? commessa;
  DateTime? dataInizio;
  DateTime? dataFine;
  Duration? stima;
  String? note;
  List<WorkflowTransitions>? workflowTransitions;

  Task({
    required this.id,
    required this.code,
    required this.description,
    required this.statusCode,
    this.priority,
    this.actionType,
    this.cliente,
    this.commessa,
    this.dataInizio,
    this.dataFine,
    this.stima,
    this.note,
    this.workflowTransitions,
  });
}
