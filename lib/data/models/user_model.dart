import 'package:trao_doi_do_app/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.roleID,
    required super.roleName,
    required super.email,
    required super.fullName,
    required super.avatar,
    required super.phoneNumber,
    required super.address,
    required super.major,
    required super.status,
    required super.goodPoint,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      roleID: json['roleID'] ?? 0,
      roleName: json['roleName'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      avatar: json['avatar'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      major: json['major'] ?? '',
      status: json['status'] ?? 0,
      goodPoint: json['goodPoint'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleID': roleID,
      'roleName': roleName,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'phoneNumber': phoneNumber,
      'address': address,
      'major': major,
      'status': status,
      'goodPoint': goodPoint,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      roleID: user.roleID,
      roleName: user.roleName,
      email: user.email,
      fullName: user.fullName,
      avatar: user.avatar,
      phoneNumber: user.phoneNumber,
      address: user.address,
      major: user.major,
      status: user.status,
      goodPoint: user.goodPoint,
    );
  }
}

class LoginResponseModel extends LoginResponse {
  const LoginResponseModel({
    required super.jwt,
    required super.refreshToken,
    required super.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      jwt: json['jwt'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class LoginRequestModel extends LoginRequest {
  const LoginRequestModel({
    required super.device,
    required super.email,
    required super.password,
  });

  factory LoginRequestModel.fromEntity(LoginRequest request) {
    return LoginRequestModel(
      device: request.device,
      email: request.email,
      password: request.password,
    );
  }
}