class Box {
  String? id;
  String code;
  String description;
  String? eqptType;
  String statusCode;

  Box({
    required this.id,
    required this.code,
    required this.description,
    this.eqptType,
    required this.statusCode,
  });
}
