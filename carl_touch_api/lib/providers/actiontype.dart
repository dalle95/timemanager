import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class ActionType {
  final String id;
  final String code;
  final String description;

  ActionType({
    @required this.id,
    @required this.code,
    @required this.description,
  });
}
