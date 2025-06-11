import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/utils/device_utils.dart';
import 'package:trao_doi_do_app/data/datasources/local/auth_local_datasource.dart';

class ApiInterceptor extends Interceptor {
  final Ref ref;
  bool _isRefreshing = false;
  final List<RequestOptions> _requestsQueue = [];

  ApiInterceptor(this.ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Always add device ID
      final deviceId = await DeviceUtils.getDeviceId();
      options.headers['Device-Id'] = deviceId;

      // Check if this request needs authentication
      final requiresAuth = options.extra['requiresAuth'] ?? true;

      if (requiresAuth) {
        final authDataSource = ref.read(authLocalDataSourceProvider);
        final token = await authDataSource.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
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
    if (err.response?.statusCode == 401) {
      // Nếu đang refresh token, thêm vào queue
      if (_isRefreshing) {
        _requestsQueue.add(err.requestOptions);
        return;
      }

      final authDataSource = ref.read(authLocalDataSourceProvider);
      final refreshToken = await authDataSource.getRefreshToken();

      if (refreshToken != null) {
        _isRefreshing = true;

        try {
          final response = await _refreshToken(refreshToken);
          final newAccessToken = response['jwt'];

          // Lưu token mới
          await authDataSource.saveAccessToken(newAccessToken);

          // Process queued requests
          await _processQueuedRequests(newAccessToken);

          // Retry original request
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await Dio().fetch(requestOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Refresh token failed, clear all tokens
          await _clearAuthData();
          // Process queued requests with error
          await _processQueuedRequestsWithError();
        } finally {
          _isRefreshing = false;
        }
      } else {
        // Không có refresh token, clear tokens
        await _clearAuthData();
      }
    }

    return handler.next(err);
  }

  Future<Map<String, dynamic>> _refreshToken(String refreshToken) async {
    final dio = Dio();
    dio.options.baseUrl = ApiConstants.baseUrl;

    final response = await dio.post(
      '/refresh-token',
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {ApiConstants.contentType: ApiConstants.applicationJson},
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == 200) {
        return data['data'];
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
        error: 'Refresh token failed',
      );
    }
  }

  Future<void> _processQueuedRequests(String newAccessToken) async {
    for (final request in _requestsQueue) {
      request.headers['Authorization'] = 'Bearer $newAccessToken';
      // Retry each queued request (implement as needed)
    }
    _requestsQueue.clear();
  }

  Future<void> _processQueuedRequestsWithError() async {
    // Clear queued requests when refresh fails
    _requestsQueue.clear();
  }

  Future<void> _clearAuthData() async {
    final authDataSource = ref.read(authLocalDataSourceProvider);
    await authDataSource.clearTokens();
    await authDataSource.clearUserInfo();
  }
}
