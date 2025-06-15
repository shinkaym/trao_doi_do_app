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
