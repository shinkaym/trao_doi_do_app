import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final deviceId = await DeviceUtils.getDeviceId();
    options.headers['Device-Id'] = deviceId;

    final authDataSource = ref.read(authLocalDataSourceProvider);
    final token = await authDataSource.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Xử lý lỗi 401 - token hết hạn
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic
    }

    super.onError(err, handler);
  }
}
