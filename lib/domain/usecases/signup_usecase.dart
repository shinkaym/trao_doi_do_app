import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/auth_request.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository _repository;

  SignupUseCase(this._repository);

  Future<Either<Failure, void>> execute(SignupRequest request) async {
    // Validation
    if (request.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email không được để trống'));
    }

    if (!_isValidEmail(request.email)) {
      return const Left(ValidationFailure('Email không hợp lệ'));
    }

    if (request.fullName.trim().isEmpty) {
      return const Left(ValidationFailure('Họ tên không được để trống'));
    }

    if (request.fullName.trim().length < 2) {
      return const Left(ValidationFailure('Họ tên phải có ít nhất 2 ký tự'));
    }

    if (request.phoneNumber.trim().isEmpty) {
      return const Left(ValidationFailure('Số điện thoại không được để trống'));
    }

    if (!_isValidPhoneNumber(request.phoneNumber)) {
      return const Left(ValidationFailure('Số điện thoại không hợp lệ'));
    }

    if (request.password.trim().isEmpty) {
      return const Left(ValidationFailure('Mật khẩu không được để trống'));
    }

    if (request.password.length < 6) {
      return const Left(ValidationFailure('Mật khẩu phải có ít nhất 6 ký tự'));
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

    return await _repository.signup(request);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhoneNumber(String phone) {
    // Vietnamese phone number validation
    return RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$').hasMatch(phone);
  }
}
