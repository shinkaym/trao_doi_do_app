import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, LoginResponse>> call(LoginRequest request) async {
    // Validation
    if (request.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email không được để trống'));
    }

    if (!_isValidEmail(request.email)) {
      return const Left(ValidationFailure('Email không hợp lệ'));
    }

    if (request.password.trim().isEmpty) {
      return const Left(ValidationFailure('Mật khẩu không được để trống'));
    }

    if (request.password.length < 6) {
      return const Left(ValidationFailure('Mật khẩu phải có ít nhất 6 ký tự'));
    }

    return await _repository.login(request);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
