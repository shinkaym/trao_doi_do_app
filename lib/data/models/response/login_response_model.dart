import 'package:trao_doi_do_app/data/models/user_model.dart';
import 'package:trao_doi_do_app/domain/entities/response/login_response.dart';

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
