import 'package:equatable/equatable.dart';

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
}

class UpdateProfileRequest extends Equatable {
  final String? address;
  final String? avatar;
  final String fullName;
  final String major;
  final String phoneNumber;

  const UpdateProfileRequest({
    this.address,
    this.avatar,
    required this.fullName,
    required this.major,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [address, avatar, fullName, major, phoneNumber];
}

class SendOtpRequest extends Equatable {
  final String email;
  final String purpose; // "activeAccount" or "resetPassword"

  const SendOtpRequest({required this.email, required this.purpose});

  @override
  List<Object?> get props => [email, purpose];
}

class VerifyOtpRequest extends Equatable {
  final String email;
  final String otp;
  final String purpose; // "activeAccount" or "resetPassword"

  const VerifyOtpRequest({
    required this.email,
    required this.otp,
    required this.purpose,
  });

  @override
  List<Object?> get props => [email, otp, purpose];
}

class SignupRequest extends Equatable {
  final String email;
  final String fullName;
  final String password;
  final String phoneNumber;
  final String rePassword;
  final String verifyToken;

  const SignupRequest({
    required this.email,
    required this.fullName,
    required this.password,
    required this.phoneNumber,
    required this.rePassword,
    required this.verifyToken,
  });

  @override
  List<Object?> get props => [
    email,
    fullName,
    password,
    phoneNumber,
    rePassword,
    verifyToken,
  ];
}

class ResetPasswordRequest extends Equatable {
  final String email;
  final String password;
  final String rePassword;
  final String verifyToken;

  const ResetPasswordRequest({
    required this.email,
    required this.password,
    required this.rePassword,
    required this.verifyToken,
  });

  @override
  List<Object?> get props => [email, password, rePassword, verifyToken];
}
