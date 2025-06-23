import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/item_warehouse_response.dart';
import 'package:trao_doi_do_app/domain/repositories/item_warehouse_repository.dart';

class GetClaimRequestsUseCase {
  final ItemWarehouseRepository _repository;

  GetClaimRequestsUseCase(this._repository);

  Future<Either<Failure, GetClaimRequestsResponse>> call() async {
    return await _repository.getClaimRequests();
  }
}
