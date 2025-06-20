import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/repositories/interest_repository.dart';

class GetInterestDetailUseCase {
  final InterestRepository _repository;

  GetInterestDetailUseCase(this._repository);

  Future<Either<Failure, InterestPost>> call(int interestID) async {
    if (interestID <= 0) {
      return const Left(ValidationFailure('Interest ID không hợp lệ'));
    }

    return await _repository.getInterestDetail(interestID);
  }
}
