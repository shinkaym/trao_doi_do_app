import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/transaction_request.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  final TransactionRepository _repository;

  UpdateTransactionUseCase(this._repository);

  Future<Either<Failure, Transaction>> call(
    int transactionID,
    UpdateTransactionRequest request,
  ) async {
    // Validation
    if (transactionID <= 0) {
      return const Left(ValidationFailure('Transaction ID không hợp lệ'));
    }

    if (request.items.isEmpty) {
      return const Left(
        ValidationFailure('Danh sách món đồ không được để trống'),
      );
    }

    // Validate status
    if (request.status < 1 || request.status > 3) {
      return const Left(
        ValidationFailure(
          'Trạng thái không hợp lệ (1: Pending, 2: Success, 3: Cancelled)',
        ),
      );
    }

    // Validate items
    for (final item in request.items) {
      if (item.postItemID <= 0) {
        return const Left(ValidationFailure('Post Item ID không hợp lệ'));
      }
      if (item.quantity <= 0) {
        return const Left(ValidationFailure('Số lượng phải lớn hơn 0'));
      }
      if (item.transactionID <= 0) {
        return const Left(
          ValidationFailure('Transaction ID trong item không hợp lệ'),
        );
      }
    }

    return await _repository.updateTransaction(transactionID, request);
  }
}
