import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';
import 'package:trao_doi_do_app/domain/repositories/item_warehouse_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/params/old_stock_query.dart';

class GetOldStockUseCase {
  final ItemWarehouseRepository _repository;

  GetOldStockUseCase(this._repository);

  Future<Either<Failure, OldStockResponse>> call(OldStockQuery query) async {
    return await _repository.getOldStock(query);
  }
}
