import 'package:dio/dio.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/request/login_request_model.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<String> logout();
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

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => LoginResponseModel.fromJson(data as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<String> logout() async {
    final response = await _dioClient.post(ApiConstants.clientLogout);

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => data.toString(),
    );

    return result.data!;
  }

  @override
  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      ApiConstants.refreshToken,
      data: {'refreshToken': refreshToken},
      options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => RefreshTokenResponse.fromJson(data as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<GetMeResponseModel> getMe() async {
    final response = await _dioClient.get(ApiConstants.clientGetMe);

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => GetMeResponseModel.fromJson(data as Map<String, dynamic>),
    );

    return result.data!;
  }
}
