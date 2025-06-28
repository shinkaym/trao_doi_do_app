import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/auth_request.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<Either<Failure, String>> execute(VerifyOtpRequest request) async {
    // Validation
    if (request.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email không được để trống'));
    }

    if (!_isValidEmail(request.email)) {
      return const Left(ValidationFailure('Email không hợp lệ'));
    }

    if (request.otp.trim().isEmpty) {
      return const Left(ValidationFailure('Mã OTP không được để trống'));
    }

    if (request.otp.length != 6) {
      return const Left(ValidationFailure('Mã OTP phải có 6 chữ số'));
    }

    if (!RegExp(r'^\d{6}$').hasMatch(request.otp)) {
      return const Left(ValidationFailure('Mã OTP chỉ được chứa số'));
    }

    if (request.purpose.trim().isEmpty) {
      return const Left(
        ValidationFailure('Mục đích xác thực không được để trống'),
      );
    }

    if (!['activeAccount', 'resetPassword'].contains(request.purpose)) {
      return const Left(ValidationFailure('Mục đích xác thực không hợp lệ'));
    }

    return await _repository.verifyOtp(request);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
