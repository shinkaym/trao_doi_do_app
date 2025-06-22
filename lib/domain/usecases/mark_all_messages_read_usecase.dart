import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/message_repository.dart';

class MarkAllMessagesReadUseCase {
  final MessageRepository _repository;

  MarkAllMessagesReadUseCase(this._repository);

  Future<Either<Failure, dynamic>> call(int interestID) async {
    if (interestID <= 0) {
      return const Left(ValidationFailure('Interest ID không hợp lệ'));
    }

    return await _repository.markAllAsRead(interestID);
  }
}
