import 'dart:async';
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

  ApiInterceptor(this.ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
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

      handler.next(options);
    } catch (e) {
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
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle auth errors for authenticated requests
    if (err.response?.statusCode == 401 &&
        (err.requestOptions.extra['requiresAuth'] ?? true)) {
      
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < _maxRetryAttempts) {
        try {
          final newToken = await _handleTokenRefreshWithQueue(err.requestOptions);
          if (newToken != null) {
            // Retry the original request with new token
            final retryResponse = await _retryRequestWithBackoff(
              err.requestOptions,
              newToken,
              retryCount,
            );
            return handler.resolve(retryResponse);
          }
        } catch (refreshError) {
          // Token refresh failed, clear auth data and let error propagate
          await _clearAuthDataAndNotify();
        }
      } else {
        // Max retries reached, clear auth data
        await _clearAuthDataAndNotify();
      }
    }

    return handler.next(err);
  }

  /// Handles token refresh using centralized service
  Future<String?> _handleTokenRefreshWithQueue(RequestOptions originalRequest) async {
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

  /// Performs the actual HTTP call to refresh token (removed - now handled by TokenRefreshService)
  // This method is now moved to TokenRefreshService

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
      extra: {
        ...requestOptions.extra,
        'retryCount': retryCount + 1,
      },
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