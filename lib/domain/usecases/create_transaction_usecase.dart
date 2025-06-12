import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/models/transaction_model.dart';
import 'package:trao_doi_do_app/data/repositories_impl/transaction_repository_impl.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository _repository;

  CreateTransactionUseCase(this._repository);

  Future<Either<Failure, Transaction>> call(
    CreateTransactionModel transaction,
  ) async {
    // Validation
    if (transaction.interestID <= 0) {
      return const Left(ValidationFailure('Interest ID không hợp lệ'));
    }

    if (transaction.items.isEmpty) {
      return const Left(
        ValidationFailure('Danh sách món đồ không được để trống'),
      );
    }

    // Validate items
    for (final item in transaction.items) {
      if (item.postItemID <= 0) {
        return const Left(ValidationFailure('Post Item ID không hợp lệ'));
      }
      if (item.quantity <= 0) {
        return const Left(ValidationFailure('Số lượng phải lớn hơn 0'));
      }
    }

    return await _repository.createTransaction(transaction);
  }
}

final createTransactionUseCaseProvider = Provider<CreateTransactionUseCase>((
  ref,
) {
  final repository = ref.watch(transactionRepositoryProvider);
  return CreateTransactionUseCase(repository);
});
