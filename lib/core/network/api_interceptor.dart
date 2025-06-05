import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/utils/device_utils.dart';
import 'package:trao_doi_do_app/data/datasources/local/auth_local_datasource.dart';

class ApiInterceptor extends Interceptor {
  final Ref ref;

  ApiInterceptor(this.ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
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

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final authDataSource = ref.read(authLocalDataSourceProvider);
      final refreshToken = await authDataSource.getRefreshToken();

      if (refreshToken != null) {
        try {
          final newTokens = await _refreshToken(refreshToken);
          final newAccessToken = newTokens['jwt'];
          final newRefreshToken = newTokens['refreshToken'];

          await authDataSource.saveAccessToken(newAccessToken);
          await authDataSource.saveRefreshToken(newRefreshToken);

          // Retry original request with new token
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await Dio().fetch(requestOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Refresh token failed
          await authDataSource.clearTokens();
          // TODO: Optional: trigger logout or navigation
        }
      } else {
        await authDataSource.clearTokens();
        // TODO: Optional: trigger logout or navigation
      }
    }

    return handler.next(err);
  }

  Future<Map<String, dynamic>> _refreshToken(String refreshToken) async {
    final response = await Dio().post(
      '${ApiConstants.baseUrl}/refresh-token',
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {ApiConstants.contentType: ApiConstants.applicationJson},
        extra: {'requiresAuth': false},
      ),
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Refresh token failed',
      );
    }
  }
}
