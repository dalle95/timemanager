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
  ActionType actionType;
  Box cliente;
  Material commessa;
  List<WorkflowTransitions> workflowTransitions;

  Task({
    @required this.id,
    @required this.code,
    @required this.description,
    @required this.statusCode,
    @required this.actionType,
    this.cliente,
    this.commessa,
    this.workflowTransitions,
  });
}
