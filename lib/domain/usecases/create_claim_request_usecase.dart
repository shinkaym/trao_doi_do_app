import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/item_warehouse_request.dart';
import 'package:trao_doi_do_app/domain/entities/response/item_warehouse_response.dart';
import 'package:trao_doi_do_app/domain/repositories/item_warehouse_repository.dart';

class CreateClaimRequestUseCase {
  final ItemWarehouseRepository _repository;

  CreateClaimRequestUseCase(this._repository);

  Future<Either<Failure, ClaimItemResponse>> call(
    List<ClaimItemRequest> claimItems,
  ) async {
    // Validation
    if (claimItems.isEmpty) {
      return const Left(
        ValidationFailure('Danh sách claim không được để trống'),
      );
    }

    for (final item in claimItems) {
      if (item.itemID <= 0) {
        return const Left(ValidationFailure('ID món đồ không hợp lệ'));
      }
      if (item.quantity <= 0) {
        return const Left(ValidationFailure('Số lượng phải lớn hơn 0'));
      }
    }

    return await _repository.createClaimRequest(claimItems);
  }
}
