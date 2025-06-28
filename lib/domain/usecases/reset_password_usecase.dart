import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/auth_request.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> execute(ResetPasswordRequest request) async {
    // Validation
    if (request.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email không được để trống'));
    }

    if (!_isValidEmail(request.email)) {
      return const Left(ValidationFailure('Email không hợp lệ'));
    }

    if (request.password.trim().isEmpty) {
      return const Left(ValidationFailure('Mật khẩu mới không được để trống'));
    }

    if (request.password.length < 6) {
      return const Left(
        ValidationFailure('Mật khẩu mới phải có ít nhất 6 ký tự'),
      );
    }

    if (request.rePassword.trim().isEmpty) {
      return const Left(
        ValidationFailure('Xác nhận mật khẩu không được để trống'),
      );
    }

    if (request.password != request.rePassword) {
      return const Left(ValidationFailure('Mật khẩu xác nhận không khớp'));
    }

    if (request.verifyToken.trim().isEmpty) {
      return const Left(ValidationFailure('Token xác thực không hợp lệ'));
    }

    return await _repository.resetPassword(request);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
