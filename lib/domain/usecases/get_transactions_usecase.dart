import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/repositories_impl/transaction_repository_impl.dart';
import 'package:trao_doi_do_app/domain/entities/params/transactions_query.dart';
import 'package:trao_doi_do_app/domain/repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  Future<Either<Failure, TransactionsResult>> call(
    TransactionsQuery query,
  ) async {
    return await _repository.getTransactions(query);
  }
}

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTransactionsUseCase(repository);
});
