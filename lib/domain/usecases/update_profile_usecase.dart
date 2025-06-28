import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/auth_request.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, User>> execute(
    int userId,
    UpdateProfileRequest request,
  ) async {
    // Only validate fields that are being updated (not null)
    if (request.fullName != null) {
      if (request.fullName!.trim().isEmpty) {
        return const Left(ValidationFailure('Họ tên không được để trống'));
      }
    }

    if (request.phoneNumber != null) {
      if (request.phoneNumber!.trim().isEmpty) {
        return const Left(
          ValidationFailure('Số điện thoại không được để trống'),
        );
      }
      if (!_isValidPhoneNumber(request.phoneNumber!)) {
        return const Left(ValidationFailure('Số điện thoại không hợp lệ'));
      }
    }

    if (request.major != null) {
      if (request.major!.trim().isEmpty) {
        return const Left(
          ValidationFailure('Chuyên ngành không được để trống'),
        );
      }
    }

    if (request.address != null) {
      if (request.address!.trim().isEmpty) {
        return const Left(ValidationFailure('Địa chỉ không được để trống'));
      }
    }

    return await _repository.updateProfile(userId, request);
  }

  bool _isValidPhoneNumber(String phone) {
    // Vietnamese phone number validation
    return RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$').hasMatch(phone);
  }
}
