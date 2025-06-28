import 'package:dio/dio.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/request/auth_request_model.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<String> logout();
  Future<RefreshTokenResponse> refreshToken(String refreshToken);
  Future<GetMeResponseModel> getMe();
  
  // NEW: Profile update
  Future<UpdateProfileResponseModel> updateProfile(
    int userId, 
    UpdateProfileRequestModel request,
  );
  
  // NEW: OTP operations
  Future<void> sendOtp(SendOtpRequestModel request);
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpRequestModel request);
  
  // NEW: Account operations
  Future<void> signup(SignupRequestModel request);
  Future<void> resetPassword(ResetPasswordRequestModel request);
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

  // NEW: Update profile implementation
  @override
  Future<UpdateProfileResponseModel> updateProfile(
    int userId,
    UpdateProfileRequestModel request,
  ) async {
    final response = await _dioClient.patch(
      '${ApiConstants.clients}/$userId',
      data: request.toJson(),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => UpdateProfileResponseModel.fromJson(data as Map<String, dynamic>),
    );

    return result.data!;
  }

  // NEW: Send OTP implementation
  @override
  Future<void> sendOtp(SendOtpRequestModel request) async {
    final response = await _dioClient.post(
      ApiConstants.clientSendOtp,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => BaseResponseModel.fromJson(data as Map<String, dynamic>),
    );

    // Success if no exception thrown
  }

  // NEW: Verify OTP implementation
  @override
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpRequestModel request) async {
    final response = await _dioClient.post(
      ApiConstants.clientVerifyOtp,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => VerifyOtpResponseModel.fromJson(data as Map<String, dynamic>),
    );

    return result.data!;
  }

  // NEW: Signup implementation
  @override
  Future<void> signup(SignupRequestModel request) async {
    final response = await _dioClient.post(
      ApiConstants.clientSignup,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => BaseResponseModel.fromJson(data as Map<String, dynamic>),
    );

    // Success if no exception thrown
  }

  // NEW: Reset password implementation
  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    final response = await _dioClient.post(
      ApiConstants.clientResetPassword,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => BaseResponseModel.fromJson(data as Map<String, dynamic>),
    );

    // Success if no exception thrown
  }
}