import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/repositories/transaction_repository.dart';

class GetTransactionByInterestUseCase {
  final TransactionRepository _repository;

  GetTransactionByInterestUseCase(this._repository);

  Future<Either<Failure, Transaction>> call(int interestID) async {
    if (interestID <= 0) {
      return const Left(ValidationFailure('Interest ID không hợp lệ'));
    }

    return await _repository.getTransactionByInterestId(interestID);
  }
}
