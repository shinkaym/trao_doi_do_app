import 'package:trao_doi_do_app/domain/entities/request/auth_request.dart';

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

class UpdateProfileRequestModel {
  final String? address;
  final String? avatar;
  final String? fullName;
  final String? major;
  final String? phoneNumber;

  const UpdateProfileRequestModel({
    this.address,
    this.avatar,
    this.fullName,
    this.major,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (fullName != null) data['fullName'] = fullName;
    if (major != null) data['major'] = major;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address;
    if (avatar != null) data['avatar'] = avatar;

    return data;
  }

  UpdateProfileRequest toEntity() {
    return UpdateProfileRequest(
      address: address,
      avatar: avatar,
      fullName: fullName,
      major: major,
      phoneNumber: phoneNumber,
    );
  }

  factory UpdateProfileRequestModel.fromEntity(UpdateProfileRequest entity) {
    return UpdateProfileRequestModel(
      address: entity.address,
      avatar: entity.avatar,
      fullName: entity.fullName,
      major: entity.major,
      phoneNumber: entity.phoneNumber,
    );
  }
}

class SendOtpRequestModel {
  final String email;
  final String purpose; // "activeAccount" or "resetPassword"

  const SendOtpRequestModel({required this.email, required this.purpose});

  Map<String, dynamic> toJson() {
    return {'email': email, 'purpose': purpose};
  }

  SendOtpRequest toEntity() {
    return SendOtpRequest(email: email, purpose: purpose);
  }

  factory SendOtpRequestModel.fromEntity(SendOtpRequest entity) {
    return SendOtpRequestModel(email: entity.email, purpose: entity.purpose);
  }
}

class VerifyOtpRequestModel {
  final String email;
  final String otp;
  final String purpose; // "activeAccount" or "resetPassword"

  const VerifyOtpRequestModel({
    required this.email,
    required this.otp,
    required this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp, 'purpose': purpose};
  }

  VerifyOtpRequest toEntity() {
    return VerifyOtpRequest(email: email, otp: otp, purpose: purpose);
  }

  factory VerifyOtpRequestModel.fromEntity(VerifyOtpRequest entity) {
    return VerifyOtpRequestModel(
      email: entity.email,
      otp: entity.otp,
      purpose: entity.purpose,
    );
  }
}

class SignupRequestModel {
  final String email;
  final String fullName;
  final String password;
  final String phoneNumber;
  final String rePassword;
  final String verifyToken;

  const SignupRequestModel({
    required this.email,
    required this.fullName,
    required this.password,
    required this.phoneNumber,
    required this.rePassword,
    required this.verifyToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'password': password,
      'phoneNumber': phoneNumber,
      'rePassword': rePassword,
      'verifyToken': verifyToken,
    };
  }

  SignupRequest toEntity() {
    return SignupRequest(
      email: email,
      fullName: fullName,
      password: password,
      phoneNumber: phoneNumber,
      rePassword: rePassword,
      verifyToken: verifyToken,
    );
  }

  factory SignupRequestModel.fromEntity(SignupRequest entity) {
    return SignupRequestModel(
      email: entity.email,
      fullName: entity.fullName,
      password: entity.password,
      phoneNumber: entity.phoneNumber,
      rePassword: entity.rePassword,
      verifyToken: entity.verifyToken,
    );
  }
}

class ResetPasswordRequestModel {
  final String email;
  final String password;
  final String rePassword;
  final String verifyToken;
  final String? currentPassword;

  const ResetPasswordRequestModel({
    required this.email,
    required this.password,
    required this.rePassword,
    required this.verifyToken,
    this.currentPassword,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'rePassword': rePassword,
      'verifyToken': verifyToken,
    };

    if (currentPassword != null) data['currentPassword'] = currentPassword;

    return data;
  }

  ResetPasswordRequest toEntity() {
    return ResetPasswordRequest(
      email: email,
      password: password,
      rePassword: rePassword,
      verifyToken: verifyToken,
    );
  }

  factory ResetPasswordRequestModel.fromEntity(ResetPasswordRequest entity) {
    return ResetPasswordRequestModel(
      email: entity.email,
      password: entity.password,
      rePassword: entity.rePassword,
      verifyToken: entity.verifyToken,
    );
  }
}
