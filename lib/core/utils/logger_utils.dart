import 'dart:convert';

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
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    int? statusCode,
    dynamic response,
  });
  void logNavigation(String from, String to);
  void logUserAction(String action, [Map<String, dynamic>? data]);
}

class LoggerUtils implements ILogger {
  final Logger _logger = Logger(
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

  // Configuration for truncating long values
  static const int _maxValueLength = 100;
  static const int _maxResponseLength = 1000;

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
    Map<String, dynamic>? queryParameters,
    dynamic body,
    int? statusCode,
    dynamic response,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final isError =
        statusCode != null && (statusCode < 200 || statusCode >= 300);

    // Build the log message with better formatting
    final buffer = StringBuffer();
    buffer.writeln(
      '🌐 ═══════════════════════════════════════════════════════',
    );
    buffer.writeln('🕐 Time: $timestamp');
    buffer.writeln('📍 Method: $method');
    buffer.writeln('🔗 URL: $url');

    // Query Parameters section
    if (queryParameters != null && queryParameters.isNotEmpty) {
      buffer.writeln('🔍 Query Parameters:');
      queryParameters.forEach((key, value) {
        buffer.writeln('   $key: $value');
      });
    }

    // Headers section
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('📋 Headers:');
      headers.forEach((key, value) {
        buffer.writeln('   $key: $value');
      });
    }

    // Request body section
    if (body != null) {
      buffer.writeln('📤 Request Body:');
      final formattedBody = _formatForLogging(body, _maxValueLength);
      buffer.writeln('   $formattedBody');
    }

    // Response section
    if (statusCode != null) {
      final statusEmoji = _getStatusEmoji(statusCode);
      buffer.writeln(
        '📊 Status: $statusEmoji $statusCode ${_getStatusText(statusCode)}',
      );
    }

    if (response != null) {
      buffer.writeln('📥 Response:');
      final formattedResponse = _formatForLogging(response, _maxValueLength);
      buffer.writeln('   $formattedResponse');
    }

    buffer.writeln('════════════════════════════════════════════════════════');

    // Log with appropriate level based on status code
    if (isError) {
      if (statusCode >= 500) {
        e(buffer.toString());
      } else {
        w(buffer.toString());
      }
    } else {
      i(buffer.toString());
    }
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

  /// Formats data for better readability in logs with length limits
  String _formatForLogging(dynamic data, [int? maxLength]) {
    if (data == null) return 'null';

    try {
      if (data is String) {
        // Try to parse as JSON for pretty printing
        try {
          final jsonData = jsonDecode(data);
          return _prettyPrintJson(jsonData, maxLength);
        } catch (_) {
          return _truncateString(data, maxLength ?? _maxValueLength);
        }
      } else if (data is Map || data is List) {
        return _prettyPrintJson(data, maxLength);
      } else {
        final dataStr = data.toString();
        return _truncateString(dataStr, maxLength ?? _maxValueLength);
      }
    } catch (e) {
      return 'Failed to format data: $e';
    }
  }

  /// Pretty prints JSON data with indentation and truncates long values
  String _prettyPrintJson(dynamic json, [int? maxLength]) {
    try {
      // First, truncate long values in the data structure
      final truncatedJson = _truncateLongValues(
        json,
        maxLength ?? _maxValueLength,
      );

      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(truncatedJson);

      // If the entire JSON string is too long, truncate it
      if (jsonString.length > _maxResponseLength) {
        return '${jsonString.substring(0, _maxResponseLength)}... (truncated ${jsonString.length - _maxResponseLength} characters)';
      }

      return jsonString;
    } catch (e) {
      final dataStr = json.toString();
      return _truncateString(dataStr, maxLength ?? _maxValueLength);
    }
  }

  /// Recursively truncates long values in data structures
  dynamic _truncateLongValues(dynamic data, int maxLength) {
    if (data == null) return null;

    try {
      if (data is Map) {
        final truncated = <String, dynamic>{};
        data.forEach((key, value) {
          if (value is String && value.length > maxLength) {
            truncated[key] = _truncateString(value, maxLength);
          } else if (value is Map || value is List) {
            truncated[key] = _truncateLongValues(value, maxLength);
          } else {
            truncated[key] = value;
          }
        });
        return truncated;
      } else if (data is List) {
        return data
            .map((item) => _truncateLongValues(item, maxLength))
            .toList();
      } else if (data is String && data.length > maxLength) {
        return _truncateString(data, maxLength);
      }
      return data;
    } catch (e) {
      return 'Failed to truncate data: $e';
    }
  }

  /// Truncates a string to specified length with ellipsis
  String _truncateString(String str, int maxLength) {
    if (str.length <= maxLength) return str;

    // For very long strings like base64 images, show beginning and end
    if (str.startsWith('data:image/') ||
        str.startsWith('eyJ') ||
        str.length > maxLength * 2) {
      final beginLength = (maxLength * 0.3).floor();
      final endLength = (maxLength * 0.2).floor();
      final begin = str.substring(0, beginLength);
      final end = str.substring(str.length - endLength);
      return '$begin...[${str.length - maxLength} chars truncated]...$end';
    }

    return '${str.substring(0, maxLength)}... (${str.length - maxLength} chars truncated)';
  }

  /// Gets emoji based on HTTP status code
  String _getStatusEmoji(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return '✅'; // Success
    } else if (statusCode >= 300 && statusCode < 400) {
      return '🔄'; // Redirect
    } else if (statusCode >= 400 && statusCode < 500) {
      return '⚠️'; // Client error
    } else if (statusCode >= 500) {
      return '❌'; // Server error
    } else {
      return '❓'; // Unknown
    }
  }

  /// Gets status text description
  String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 422:
        return 'Unprocessable Entity';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      default:
        return '';
    }
  }
}