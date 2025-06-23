import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/item_warehouse_remote_datasource.dart';
import 'package:trao_doi_do_app/data/models/request/item_warehouse_request_model.dart';
import 'package:trao_doi_do_app/domain/entities/request/item_warehouse_request.dart';
import 'package:trao_doi_do_app/domain/entities/response/item_warehouse_response.dart';
import 'package:trao_doi_do_app/domain/repositories/item_warehouse_repository.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/usecases/params/old_stock_query.dart';

class ItemWarehouseRepositoryImpl implements ItemWarehouseRepository {
  final ItemWarehouseRemoteDataSource _remoteDataSource;

  ItemWarehouseRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ClaimItemResponse>> createClaimRequest(
    List<ClaimItemRequest> claimItems,
  ) async {
    return handleRepositoryCall<ClaimItemResponse>(() async {
      final claimItemModels =
          claimItems
              .map((item) => ClaimItemRequestModel.fromEntity(item))
              .toList();
      final result = await _remoteDataSource.createClaimRequest(
        claimItemModels,
      );
      return result.toEntity();
    }, 'Lỗi tạo yêu cầu claim');
  }

  @override
  Future<Either<Failure, String>> updateClaimRequest(
    int itemID,
    int newQuantity,
  ) async {
    return handleRepositoryCall<String>(() async {
      final result = await _remoteDataSource.updateClaimRequest(
        itemID,
        newQuantity,
      );
      return result;
    }, 'Lỗi cập nhật yêu cầu claim');
  }

  @override
  Future<Either<Failure, OldStockResponse>> getOldStock(
    OldStockQuery query,
  ) async {
    return handleRepositoryCall<OldStockResponse>(() async {
      final result = await _remoteDataSource.getOldStock(query);
      return result.toEntity();
    }, 'Lỗi tải danh sách kho cũ');
  }
}
