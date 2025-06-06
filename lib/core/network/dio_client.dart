import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'api_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
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

  return dio;
});

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Kết nối timeout');
        case DioExceptionType.connectionError:
          return NetworkException('Lỗi kết nối mạng');
        case DioExceptionType.badResponse:
          return ServerException(
            error.response?.data['message'] ?? 'Lỗi server',
            error.response?.statusCode,
          );
        default:
          return ServerException('Lỗi không xác định');
      }
    }
    return ServerException('Lỗi không xác định');
  }
}

final dioClientProvider = Provider<DioClient>((ref) {
  final dio = ref.watch(dioProvider);
  return DioClient(dio);
});
