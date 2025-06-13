import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/utils/device_utils.dart';
import 'package:trao_doi_do_app/data/datasources/local/auth_local_datasource.dart';

class ApiInterceptor extends Interceptor {
  final Ref ref;
  bool _isRefreshing = false;
  Completer<String>? _refreshCompleter;

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
    if (err.response?.statusCode == 401 &&
        (err.requestOptions.extra['requiresAuth'] ?? true)) {
      try {
        final newToken = await _handleTokenRefresh();
        if (newToken != null) {
          // Retry the original request with new token
          final retryResponse = await _retryRequest(
            err.requestOptions,
            newToken,
          );
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        // Token refresh failed, clear auth data
        await _clearAuthData();
        // Let the error propagate to trigger logout in UI
      }
    }

    return handler.next(err);
  }

  Future<String?> _handleTokenRefresh() async {
    // If already refreshing, wait for the existing refresh to complete
    if (_isRefreshing && _refreshCompleter != null) {
      try {
        return await _refreshCompleter!.future;
      } catch (e) {
        return null;
      }
    }

    // Start new refresh process
    _isRefreshing = true;
    _refreshCompleter = Completer<String>();

    try {
      final authDataSource = ref.read(authLocalDataSourceProvider);
      final refreshToken = await authDataSource.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final newAccessToken = await _refreshToken(refreshToken);

      // Save new token
      await authDataSource.saveAccessToken(newAccessToken);

      // Complete the completer with success
      _refreshCompleter!.complete(newAccessToken);

      return newAccessToken;
    } catch (e) {
      // Complete the completer with error
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<String> _refreshToken(String refreshToken) async {
    final dio = Dio();
    dio.options.baseUrl = ApiConstants.baseUrl;

    // Add device ID to refresh token request
    final deviceId = await DeviceUtils.getDeviceId();

    final response = await dio.post(
      '/refresh-token',
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
          ApiConstants.deviceId: deviceId,
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == 200 && data['data'] != null) {
        final newAccessToken = data['data']['jwt'];
        if (newAccessToken == null) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'Access token not found in refresh response',
          );
        }
        return newAccessToken;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: data['message'] ?? 'Refresh token failed',
        );
      }
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Refresh token failed with status: ${response.statusCode}',
      );
    }
  }

  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newToken,
  ) async {
    // Create new request options with updated token
    final newOptions = requestOptions.copyWith();
    newOptions.headers[ApiConstants.authorization] = 'Bearer $newToken';

    // Use a new Dio instance to avoid interceptor loops
    final retryDio = Dio();
    retryDio.options.baseUrl = ApiConstants.baseUrl;
    retryDio.options.connectTimeout = Duration(
      milliseconds: ApiConstants.connectTimeout,
    );
    retryDio.options.receiveTimeout = Duration(
      milliseconds: ApiConstants.receiveTimeout,
    );

    return await retryDio.fetch(newOptions);
  }

  Future<void> _clearAuthData() async {
    try {
      final authDataSource = ref.read(authLocalDataSourceProvider);
      await authDataSource.clearTokens();
      await authDataSource.clearUserInfo();
    } catch (e) {
      // Log error but don't throw to avoid masking the original error
      print('Error clearing auth data: $e');
    }
  }
}
