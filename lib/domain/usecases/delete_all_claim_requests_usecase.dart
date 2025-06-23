import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/item_warehouse_repository.dart';

class DeleteAllClaimRequestsUseCase {
  final ItemWarehouseRepository _repository;

  DeleteAllClaimRequestsUseCase(this._repository);

  Future<Either<Failure, String>> call() async {
    return await _repository.deleteAllClaimRequests();
  }
}
