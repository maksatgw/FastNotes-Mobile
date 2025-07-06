class RepositoryException implements Exception {
  final String message;
  final Exception? originalError;

  RepositoryException(this.message, {this.originalError});

  @override
  String toString() => 'RepositoryException: $message';
}
