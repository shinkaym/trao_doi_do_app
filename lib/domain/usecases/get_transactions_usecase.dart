import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/transaction_response.dart';
import 'package:trao_doi_do_app/domain/usecases/params/transaction_query.dart';
import 'package:trao_doi_do_app/domain/repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  Future<Either<Failure, TransactionsResponse>> call(
    TransactionsQuery query,
  ) async {
    return await _repository.getTransactions(query);
  }
}
