import 'package:trao_doi_do_app/domain/entities/request/login_request.dart';

class LoginRequestModel {
  final String device;
  final String email;
  final String password;

  const LoginRequestModel({
    required this.device,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'device': device, 'email': email, 'password': password};
  }

  LoginRequest toEntity() {
    return LoginRequest(device: device, email: email, password: password);
  }

  factory LoginRequestModel.fromEntity(LoginRequest entity) {
    return LoginRequestModel(
      device: entity.device,
      email: entity.email,
      password: entity.password,
    );
  }
}
