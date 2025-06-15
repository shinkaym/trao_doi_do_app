import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';

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
