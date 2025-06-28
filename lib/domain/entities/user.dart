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

  User copyWith({
    int? id,
    int? roleID,
    String? roleName,
    String? email,
    String? fullName,
    String? avatar,
    String? phoneNumber,
    String? address,
    String? major,
    int? status,
    int? goodPoint,
  }) {
    return User(
      id: id ?? this.id,
      roleID: roleID ?? this.roleID,
      roleName: roleName ?? this.roleName,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      major: major ?? this.major,
      status: status ?? this.status,
      goodPoint: goodPoint ?? this.goodPoint,
    );
  }

  // MergeWith method để merge với user khác, ưu tiên dữ liệu mới nếu không null
  User mergeWith(User other) {
    return User(
      id: other.id != 0 ? other.id : id,
      roleID: other.roleID != 0 ? other.roleID : roleID,
      roleName: other.roleName.isNotEmpty ? other.roleName : roleName,
      email: other.email.isNotEmpty ? other.email : email,
      fullName: other.fullName.isNotEmpty ? other.fullName : fullName,
      avatar: other.avatar.isNotEmpty ? other.avatar : avatar,
      phoneNumber:
          other.phoneNumber.isNotEmpty ? other.phoneNumber : phoneNumber,
      address: other.address.isNotEmpty ? other.address : address,
      major: other.major.isNotEmpty ? other.major : major,
      status: other.status != 0 ? other.status : status,
      goodPoint: other.goodPoint != 0 ? other.goodPoint : goodPoint,
    );
  }

  // Factory method từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

  // Convert to JSON
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
