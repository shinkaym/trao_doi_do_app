abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);
}

class ServerException extends AppException {
  const ServerException(String message, [int? statusCode])
    : super(message, statusCode);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}
