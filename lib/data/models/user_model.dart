import 'package:trao_doi_do_app/domain/entities/user.dart';

class UserModel {
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

  const UserModel({
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

  User toEntity() {
    return User(
      id: id,
      roleID: roleID,
      roleName: roleName,
      email: email,
      fullName: fullName,
      avatar: avatar,
      phoneNumber: phoneNumber,
      address: address,
      major: major,
      status: status,
      goodPoint: goodPoint,
    );
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
