import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<void> logout();
  Future<LoginResponseModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _dioClient.post(
      ApiConstants.login,
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
    await _dioClient.post('/logout');
  }

  @override
  Future<LoginResponseModel> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      '/refresh-token',
      data: {'refreshToken': refreshToken},
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
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
});
