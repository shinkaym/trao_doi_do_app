import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/item_warehouse_repository.dart';

class UpdateClaimRequestUseCase {
  final ItemWarehouseRepository _repository;

  UpdateClaimRequestUseCase(this._repository);

  Future<Either<Failure, String>> call(int itemID, int newQuantity) async {
    // Validation
    if (itemID <= 0) {
      return const Left(ValidationFailure('ID món đồ không hợp lệ'));
    }

    if (newQuantity <= 0) {
      return const Left(ValidationFailure('Số lượng mới phải lớn hơn 0'));
    }

    return await _repository.updateClaimRequest(itemID, newQuantity);
  }
}
