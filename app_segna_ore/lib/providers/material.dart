import 'package:flutter/foundation.dart';
import '../providers/actor.dart';

class Material {
  String id;
  String code;
  String description;
  String eqptType;
  String statusCode;
  Actor responsabile;

  Material(
      {@required this.id,
      @required this.code,
      @required this.description,
      @required this.eqptType,
      @required this.statusCode,
      @required this.responsabile});
}
