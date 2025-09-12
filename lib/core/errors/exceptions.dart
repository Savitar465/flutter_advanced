class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}