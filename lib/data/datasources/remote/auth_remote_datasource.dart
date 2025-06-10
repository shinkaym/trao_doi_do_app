import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/refreshtoken_response.dart';
import 'package:trao_doi_do_app/data/models/response/get_me_response_model.dart';
import 'package:trao_doi_do_app/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<void> logout();
  Future<RefreshTokenResponse> refreshToken(String refreshToken);
  Future<GetMeResponseModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _dioClient.post(
      ApiConstants.clientLogin,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );

    final apiResponse = ApiResponseModel.fromJson(
      response.data,
      (data) => LoginResponseModel.fromJson(data as Map<String, dynamic>),
    );

    if (apiResponse.code == 200 && apiResponse.data != null) {
      return apiResponse.data!;
    } else {
      throw ServerException(apiResponse.message, apiResponse.code);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await _dioClient.post(
        ApiConstants.clientLogout,
        options: Options(extra: {'requiresAuth': true}),
      );

      // ✅ FIXED: Kiểm tra HTTP status code 200 cho logout
      if (response.statusCode != 200) {
        throw ServerException('Logout failed', response.statusCode);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Logout failed');
    }
  }

  @override
  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.post(
        '/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'requiresAuth': false}),
      );

      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (data) => RefreshTokenResponse.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.code == 200 && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ServerException(apiResponse.message, apiResponse.code);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Refresh token failed');
    }
  }

  @override
  Future<GetMeResponseModel> getMe() async {
    try {
      final response = await _dioClient.get(ApiConstants.clientGetMe);

      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (data) => GetMeResponseModel.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.code == 200 && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ServerException(apiResponse.message, apiResponse.code);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Failed to get user info');
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
});