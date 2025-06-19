import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/api_interceptor.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/core/services/token_refresh_service.dart';

/// Network Module - Contains network-related dependencies
class NetworkModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

final dioProvider = Provider.autoDispose<Dio>((ref) {
  final dio = Dio();
  dio.options.baseUrl = ApiConstants.baseUrl;
  dio.options.connectTimeout = Duration(
    milliseconds: ApiConstants.connectTimeout,
  );
  dio.options.receiveTimeout = Duration(
    milliseconds: ApiConstants.receiveTimeout,
  );
  dio.options.headers = {
    ApiConstants.contentType: ApiConstants.applicationJson,
  };
  dio.interceptors.add(ApiInterceptor(ref));

  ref.onDispose(() {
    dio.close();
  });

  return dio;
});

final dioClientProvider = Provider.autoDispose<DioClient>((ref) {
  final dio = ref.watch(dioProvider);
  return DioClient(dio);
});

final tokenRefreshServiceProvider = Provider<TokenRefreshService>((ref) {
  return TokenRefreshService();
});
