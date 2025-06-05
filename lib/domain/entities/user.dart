import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final int roleID;
  final String roleName;
  final String email;
  final String fullName;
  final String avatar;
  final String phoneNumber;
  final String address;
  final String major;
  final int status;
  final int goodPoint;

  const User({
    required this.id,
    required this.roleID,
    required this.roleName,
    required this.email,
    required this.fullName,
    required this.avatar,
    required this.phoneNumber,
    required this.address,
    required this.major,
    required this.status,
    required this.goodPoint,
  });

  @override
  List<Object?> get props => [
    id,
    roleID,
    roleName,
    email,
    fullName,
    avatar,
    phoneNumber,
    address,
    major,
    status,
    goodPoint,
  ];
}

class LoginRequest extends Equatable {
  final String device;
  final String email;
  final String password;

  const LoginRequest({
    required this.device,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [device, email, password];

  Map<String, dynamic> toJson() {
    return {'device': device, 'email': email, 'password': password};
  }
}

class LoginResponse extends Equatable {
  final String jwt;
  final String refreshToken;
  final User user;

  const LoginResponse({
    required this.jwt,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [jwt, refreshToken, user];
}
