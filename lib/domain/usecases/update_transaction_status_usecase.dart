import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/models/transaction_model.dart';
import 'package:trao_doi_do_app/data/repositories_impl/transaction_repository_impl.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/repositories/transaction_repository.dart';

class UpdateTransactionStatusUseCase {
  final TransactionRepository _repository;

  UpdateTransactionStatusUseCase(this._repository);

  Future<Either<Failure, Transaction>> call(
    int transactionID,
    int status,
  ) async {
    // Validation
    if (transactionID <= 0) {
      return const Left(ValidationFailure('Transaction ID không hợp lệ'));
    }

    // Validate status (1: Pending, 2: Success, 3: Cancelled)
    if (status < 1 || status > 3) {
      return const Left(
        ValidationFailure(
          'Trạng thái không hợp lệ (1: Pending, 2: Success, 3: Cancelled)',
        ),
      );
    }

    final updateModel = UpdateTransactionStatusModel(status: status);
    return await _repository.updateTransactionStatus(
      transactionID,
      updateModel,
    );
  }
}

final updateTransactionStatusUseCaseProvider =
    Provider<UpdateTransactionStatusUseCase>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);
      return UpdateTransactionStatusUseCase(repository);
    });
