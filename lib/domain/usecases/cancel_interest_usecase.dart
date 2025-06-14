import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/repositories/interest_repository.dart';

class CancelInterestUseCase {
  final InterestRepository _repository;

  CancelInterestUseCase(this._repository);

  Future<Either<Failure, InterestActionResult>> call(int postID) async {
    if (postID <= 0) {
      return const Left(ValidationFailure('Post ID không hợp lệ'));
    }

    return await _repository.cancelInterest(postID);
  }
}
