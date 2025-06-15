import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/utils/device_utils.dart';

class ApiInterceptor extends Interceptor {
  final Ref ref;

  // Retry configuration
  static const int _maxRetryAttempts = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  // Logging configuration
  static const int _maxLogValueLength = 100;
  static const int _maxLogBodyLength = 500;

  ApiInterceptor(this.ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final logger = ref.read(loggerProvider);

      // Always add device ID
      final deviceId = await DeviceUtils.getDeviceId();
      options.headers[ApiConstants.deviceId] = deviceId;

      // Check if this request needs authentication
      final requiresAuth = options.extra['requiresAuth'] ?? true;

      if (requiresAuth) {
        final authDataSource = ref.read(authLocalDataSourceProvider);

        // Check if we should refresh the token proactively
        if (await authDataSource.shouldRefreshAccessToken()) {
          await _handleProactiveTokenRefresh();
        }

        final token = await authDataSource.getAccessToken();
        if (token != null) {
          options.headers[ApiConstants.authorization] = 'Bearer $token';
        }
      }

      // Log the outgoing request
      _logOutgoingRequest(options, logger);

      handler.next(options);
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('Failed to prepare request: $e');

      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to prepare request: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final logger = ref.read(loggerProvider);

    // Log successful response
    _logResponse(response, logger);

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final logger = ref.read(loggerProvider);

    // Log error response
    _logErrorResponse(err, logger);

    // Only handle auth errors for authenticated requests
    if (err.response?.statusCode == 401 &&
        (err.requestOptions.extra['requiresAuth'] ?? true)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < _maxRetryAttempts) {
        try {
          final newToken = await _handleTokenRefreshWithQueue(
            err.requestOptions,
          );
          if (newToken != null) {
            // Log retry attempt
            logger.i(
              '🔄 Retrying request with new token (attempt ${retryCount + 1})',
            );

            // Retry the original request with new token
            final retryResponse = await _retryRequestWithBackoff(
              err.requestOptions,
              newToken,
              retryCount,
            );
            return handler.resolve(retryResponse);
          }
        } catch (refreshError) {
          logger.e('Token refresh failed during retry: $refreshError');
          // Token refresh failed, clear auth data and let error propagate
          await _clearAuthDataAndNotify();
        }
      } else {
        logger.w('Max retry attempts reached for ${err.requestOptions.path}');
        // Max retries reached, clear auth data
        await _clearAuthDataAndNotify();
      }
    }

    return handler.next(err);
  }

  /// Logs outgoing request details with truncated long values
  void _logOutgoingRequest(RequestOptions options, logger) {
    // Prepare headers for logging (exclude sensitive data)
    final headersForLog = Map<String, dynamic>.from(options.headers);
    if (headersForLog.containsKey(ApiConstants.authorization)) {
      headersForLog[ApiConstants.authorization] = 'Bearer ***';
    }

    // Prepare query parameters for logging
    Map<String, dynamic>? queryParamsForLog;
    if (options.queryParameters.isNotEmpty) {
      queryParamsForLog = Map<String, dynamic>.from(options.queryParameters);
      // Sanitize sensitive query parameters
      queryParamsForLog = _sanitizeAndTruncateLogData(queryParamsForLog);
    }

    // Prepare body for logging with truncation
    dynamic bodyForLog;
    if (options.data != null) {
      try {
        if (options.data is FormData) {
          final formData = options.data as FormData;
          bodyForLog = {
            'type': 'FormData',
            'fieldsCount': formData.fields.length,
            'filesCount': formData.files.length,
            'fields':
                formData.fields
                    .map(
                      (field) => {
                        'name': field.key,
                        'value':
                            _isSensitiveField(field.key.toLowerCase())
                                ? '***'
                                : _truncateString(
                                  field.value,
                                  _maxLogValueLength,
                                ),
                      },
                    )
                    .toList(),
          };
        } else if (options.data is String) {
          // Try to parse as JSON for better formatting
          try {
            final jsonData = jsonDecode(options.data);
            bodyForLog = _sanitizeAndTruncateLogData(jsonData);
          } catch (_) {
            bodyForLog = _truncateString(
              options.data.toString(),
              _maxLogBodyLength,
            );
          }
        } else {
          bodyForLog = _sanitizeAndTruncateLogData(options.data);
        }
      } catch (e) {
        bodyForLog = 'Data serialization failed: $e';
      }
    }

    logger.logApiCall(
      method: options.method.toUpperCase(),
      url: '${options.baseUrl}${options.path}',
      headers: headersForLog,
      queryParameters: queryParamsForLog,
      body: bodyForLog,
    );
  }

  /// Logs successful response with truncated long values
  void _logResponse(Response response, logger) {
    dynamic responseForLog;

    try {
      if (response.data != null) {
        responseForLog = _sanitizeAndTruncateLogData(response.data);
      }
    } catch (e) {
      responseForLog = 'Response serialization failed: $e';
    }

    // Prepare query parameters for response logging
    Map<String, dynamic>? queryParamsForLog;
    if (response.requestOptions.queryParameters.isNotEmpty) {
      queryParamsForLog = Map<String, dynamic>.from(
        response.requestOptions.queryParameters,
      );
      queryParamsForLog = _sanitizeAndTruncateLogData(queryParamsForLog);
    }

    logger.logApiCall(
      method: response.requestOptions.method.toUpperCase(),
      url: '${response.requestOptions.baseUrl}${response.requestOptions.path}',
      queryParameters: queryParamsForLog,
      statusCode: response.statusCode,
      response: responseForLog,
    );
  }

  /// Logs error response with truncated long values
  void _logErrorResponse(DioException err, logger) {
    dynamic errorResponseForLog;

    try {
      if (err.response?.data != null) {
        errorResponseForLog = _sanitizeAndTruncateLogData(err.response!.data);
      } else {
        errorResponseForLog = err.message ?? 'Unknown error';
      }
    } catch (e) {
      errorResponseForLog = 'Error response serialization failed: $e';
    }

    // Prepare query parameters for error logging
    Map<String, dynamic>? queryParamsForLog;
    if (err.requestOptions.queryParameters.isNotEmpty) {
      queryParamsForLog = Map<String, dynamic>.from(
        err.requestOptions.queryParameters,
      );
      queryParamsForLog = _sanitizeAndTruncateLogData(queryParamsForLog);
    }

    logger.logApiCall(
      method: err.requestOptions.method.toUpperCase(),
      url: '${err.requestOptions.baseUrl}${err.requestOptions.path}',
      queryParameters: queryParamsForLog,
      statusCode: err.response?.statusCode ?? 0,
      response: 'ERROR: $errorResponseForLog',
    );
  }

  /// Sanitizes and truncates data for logging by removing sensitive information and limiting length
  dynamic _sanitizeAndTruncateLogData(dynamic data) {
    if (data == null) return null;

    try {
      if (data is Map) {
        final sanitized = <String, dynamic>{};
        data.forEach((key, value) {
          final keyStr = key.toString().toLowerCase();
          if (_isSensitiveField(keyStr)) {
            sanitized[key] = '***';
          } else if (value is Map || value is List) {
            sanitized[key] = _sanitizeAndTruncateLogData(value);
          } else if (value is String && value.length > _maxLogValueLength) {
            sanitized[key] = _truncateString(value, _maxLogValueLength);
          } else {
            sanitized[key] = value;
          }
        });
        return sanitized;
      } else if (data is List) {
        return data.map((item) => _sanitizeAndTruncateLogData(item)).toList();
      } else if (data is String && data.length > _maxLogValueLength) {
        return _truncateString(data, _maxLogValueLength);
      }
      return data;
    } catch (e) {
      return 'Data sanitization failed: $e';
    }
  }

  /// Truncates a string to specified length with appropriate indicators
  String _truncateString(String str, int maxLength) {
    if (str.length <= maxLength) return str;

    // Special handling for different types of long strings
    if (_isBase64Image(str)) {
      return '${str.substring(0, 5)}...[base64 image ${str.length} chars]...${str.substring(str.length - 10)}';
    } else if (_isJwtToken(str)) {
      return '${str.substring(0, 5)}...[JWT token ${str.length} chars]...${str.substring(str.length - 10)}';
    } else if (str.length > maxLength * 2) {
      // For very long strings, show beginning and end
      final beginLength = (maxLength * 0.4).floor();
      final endLength = (maxLength * 0.2).floor();
      return '${str.substring(0, beginLength)}...[${str.length - maxLength} chars]...${str.substring(str.length - endLength)}';
    }

    return '${str.substring(0, maxLength)}... (${str.length - maxLength} chars)';
  }

  /// Checks if string is a base64 image
  bool _isBase64Image(String str) {
    return str.startsWith('data:image/') && str.contains('base64,');
  }

  /// Checks if string is a JWT token
  bool _isJwtToken(String str) {
    return str.startsWith('eyJ') ||
        (str.contains('.') && str.split('.').length == 3);
  }

  /// Checks if a field contains sensitive information
  bool _isSensitiveField(String fieldName) {
    const sensitiveFields = [
      'password',
      'token',
      'secret',
      'key',
      'authorization',
      'auth',
      'credential',
      'private',
      'confidential',
      'refreshtoken', // Add refresh token to sensitive fields
    ];

    return sensitiveFields.any((sensitive) => fieldName.contains(sensitive));
  }

  /// Handles token refresh using centralized service
  Future<String?> _handleTokenRefreshWithQueue(
    RequestOptions originalRequest,
  ) async {
    try {
      final tokenRefreshService = ref.read(tokenRefreshServiceProvider);
      final authDataSource = ref.read(authLocalDataSourceProvider);

      return await tokenRefreshService.refreshToken(authDataSource);
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('Token refresh failed: $e');
      return null;
    }
  }

  /// Proactive token refresh using centralized service
  Future<void> _handleProactiveTokenRefresh() async {
    try {
      final tokenRefreshService = ref.read(tokenRefreshServiceProvider);
      final authDataSource = ref.read(authLocalDataSourceProvider);

      // Don't wait for proactive refresh to complete
      tokenRefreshService.refreshToken(authDataSource);
    } catch (e) {
      // Ignore proactive refresh errors
    }
  }

  /// Retries request with exponential backoff
  Future<Response> _retryRequestWithBackoff(
    RequestOptions requestOptions,
    String newToken,
    int retryCount,
  ) async {
    // Calculate delay with exponential backoff
    final delay = Duration(
      milliseconds: _retryDelay.inMilliseconds * (1 << retryCount),
    );

    await Future.delayed(delay);

    // Create new request options with updated token and retry count
    final newOptions = requestOptions.copyWith(
      extra: {...requestOptions.extra, 'retryCount': retryCount + 1},
    );
    newOptions.headers[ApiConstants.authorization] = 'Bearer $newToken';

    // Use a new Dio instance to avoid interceptor loops
    final retryDio = _createRetryDio();

    return await retryDio.fetch(newOptions);
  }

  /// Creates a clean Dio instance for retry requests
  Dio _createRetryDio() {
    final retryDio = Dio();
    retryDio.options.baseUrl = ApiConstants.baseUrl;
    retryDio.options.connectTimeout = Duration(
      milliseconds: ApiConstants.connectTimeout,
    );
    retryDio.options.receiveTimeout = Duration(
      milliseconds: ApiConstants.receiveTimeout,
    );
    retryDio.options.headers = {
      ApiConstants.contentType: ApiConstants.applicationJson,
    };

    return retryDio;
  }

  /// Clears auth data and notifies the auth provider
  Future<void> _clearAuthDataAndNotify() async {
    try {
      final authDataSource = ref.read(authLocalDataSourceProvider);
      await authDataSource.clearTokens();
      await authDataSource.clearUserInfo();

      // Notify auth provider to update UI state
      // This will trigger logout in the UI
      ref.read(authProvider.notifier).handleTokenExpired();
    } catch (e) {
      // Log error but don't throw to avoid masking the original error
      final logger = ref.read(loggerProvider);
      logger.e('Error clearing auth data: $e');
    }
  }

  /// Cleanup method to be called when disposing
  void dispose() {
    final tokenRefreshService = ref.read(tokenRefreshServiceProvider);
    tokenRefreshService.forceCleanup();
  }
}
