class HttpWOOccupationDateException implements Exception {
  final String message;

  HttpWOOccupationDateException(this.message);

  @override
  String toString() {
    return message;
  }
}
