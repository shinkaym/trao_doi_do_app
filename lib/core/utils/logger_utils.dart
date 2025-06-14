import 'package:logger/logger.dart';

abstract class ILogger {
  void d(String message, [dynamic error, StackTrace? stackTrace]);
  void i(String message, [dynamic error, StackTrace? stackTrace]);
  void w(String message, [dynamic error, StackTrace? stackTrace]);
  void e(String message, [dynamic error, StackTrace? stackTrace]);
  void f(String message, [dynamic error, StackTrace? stackTrace]);
  void logApiCall({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body,
    int? statusCode,
    dynamic response,
  });
  void logNavigation(String from, String to);
  void logUserAction(String action, [Map<String, dynamic>? data]);
}

class LoggerUtils implements ILogger {
  static final LoggerUtils _instance = LoggerUtils._internal();
  late final Logger _logger;

  factory LoggerUtils() {
    return _instance;
  }

  LoggerUtils._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: Level.debug,
    );
  }

  Logger get logger => _logger;

  @override
  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  @override
  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  @override
  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  @override
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  @override
  void f(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  @override
  void logApiCall({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body,
    int? statusCode,
    dynamic response,
  }) {
    final message = '''
🌐 API Call: $method $url
📋 Headers: ${headers ?? 'None'}
📤 Body: ${body ?? 'None'}
📊 Status: $statusCode
📥 Response: $response
    ''';
    i(message);
  }

  @override
  void logNavigation(String from, String to) {
    i('🧭 Navigation: $from → $to');
  }

  @override
  void logUserAction(String action, [Map<String, dynamic>? data]) {
    final message =
        '👤 User Action: $action${data != null ? ' - Data: $data' : ''}';
    i(message);
  }
}
