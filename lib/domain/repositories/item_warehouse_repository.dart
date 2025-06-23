import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/item_warehouse_request.dart';
import 'package:trao_doi_do_app/domain/entities/response/item_warehouse_response.dart';
import 'package:trao_doi_do_app/domain/usecases/params/old_stock_query.dart';

abstract class ItemWarehouseRepository {
  Future<Either<Failure, ClaimItemResponse>> createClaimRequest(
    List<ClaimItemRequest> claimItems,
  );
  Future<Either<Failure, String>> updateClaimRequest(
    int itemID,
    int newQuantity,
  );
  Future<Either<Failure, OldStockResponse>> getOldStock(OldStockQuery query);
}
