import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/auth_request.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository _repository;

  SendOtpUseCase(this._repository);

  Future<Either<Failure, void>> execute(SendOtpRequest request) async {
    // Validation
    if (request.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email không được để trống'));
    }

    if (!_isValidEmail(request.email)) {
      return const Left(ValidationFailure('Email không hợp lệ'));
    }

    if (request.purpose.trim().isEmpty) {
      return const Left(
        ValidationFailure('Mục đích gửi OTP không được để trống'),
      );
    }

    if (!['activeAccount', 'resetPassword'].contains(request.purpose)) {
      return const Left(ValidationFailure('Mục đích gửi OTP không hợp lệ'));
    }

    return await _repository.sendOtp(request);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
