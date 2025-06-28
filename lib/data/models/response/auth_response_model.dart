import 'package:trao_doi_do_app/data/models/user_model.dart';
import 'package:trao_doi_do_app/domain/entities/response/auth_response.dart';

class LoginResponseModel {
  final String jwt;
  final String refreshToken;
  final UserModel user;

  const LoginResponseModel({
    required this.jwt,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      jwt: json['jwt'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'jwt': jwt, 'refreshToken': refreshToken, 'user': user.toJson()};
  }

  LoginResponse toEntity() {
    return LoginResponse(
      jwt: jwt,
      refreshToken: refreshToken,
      user: user.toEntity(),
    );
  }

  factory LoginResponseModel.fromEntity(LoginResponse entity) {
    return LoginResponseModel(
      jwt: entity.jwt,
      refreshToken: entity.refreshToken,
      user: UserModel.fromEntity(entity.user),
    );
  }
}

class GetMeResponseModel {
  final UserModel user;

  const GetMeResponseModel({required this.user});

  factory GetMeResponseModel.fromJson(Map<String, dynamic> json) {
    return GetMeResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson()};
  }
}

class RefreshTokenResponse {
  final String jwt;

  RefreshTokenResponse({required this.jwt});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(jwt: json['jwt'] as String);
  }
}

class UpdateProfileResponseModel {
  final UserModel client;

  const UpdateProfileResponseModel({required this.client});

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponseModel(
      client: UserModel.fromJson(json['client'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'client': client.toJson()};
  }

  UpdateProfileResponse toEntity() {
    return UpdateProfileResponse(client: client.toEntity());
  }

  factory UpdateProfileResponseModel.fromEntity(UpdateProfileResponse entity) {
    return UpdateProfileResponseModel(
      client: UserModel.fromEntity(entity.client),
    );
  }
}

class VerifyOtpResponseModel {
  final String verifyToken;

  const VerifyOtpResponseModel({required this.verifyToken});

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(verifyToken: json['verifyToken'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'verifyToken': verifyToken};
  }

  VerifyOtpResponse toEntity() {
    return VerifyOtpResponse(verifyToken: verifyToken);
  }

  factory VerifyOtpResponseModel.fromEntity(VerifyOtpResponse entity) {
    return VerifyOtpResponseModel(verifyToken: entity.verifyToken);
  }
}

class BaseResponseModel {
  // For responses that only have code and message fields
  const BaseResponseModel();

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    return const BaseResponseModel();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
