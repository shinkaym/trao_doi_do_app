import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/transaction_request.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository _repository;

  CreateTransactionUseCase(this._repository);

  Future<Either<Failure, Transaction>> call(
    CreateTransactionRequest request,
  ) async {
    // Validation
    if (request.interestID <= 0) {
      return const Left(ValidationFailure('Interest ID không hợp lệ'));
    }

    if (request.items.isEmpty) {
      return const Left(
        ValidationFailure('Danh sách món đồ không được để trống'),
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
    }

    return await _repository.createTransaction(request);
  }
}
