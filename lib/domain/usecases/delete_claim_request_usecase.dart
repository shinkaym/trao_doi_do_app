import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/item_warehouse_repository.dart';

class DeleteClaimRequestUseCase {
  final ItemWarehouseRepository _repository;

  DeleteClaimRequestUseCase(this._repository);

  Future<Either<Failure, String>> call(int itemID) async {
    // Validation
    if (itemID <= 0) {
      return const Left(ValidationFailure('ID món đồ không hợp lệ'));
    }

    return await _repository.deleteClaimRequest(itemID);
  }
}
