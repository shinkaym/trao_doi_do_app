import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/request/item_warehouse_request_model.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/item_warehouse_response_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/old_stock_query.dart';

abstract class ItemWarehouseRemoteDataSource {
  Future<ClaimItemResponseModel> createClaimRequest(
    List<ClaimItemRequestModel> claimItems,
  );
  Future<String> updateClaimRequest(int itemID, int newQuantity);
  Future<OldStockResponseModel> getOldStock(OldStockQuery query);
  Future<GetClaimRequestsResponseModel> getClaimRequests();
  Future<String> deleteClaimRequest(int itemID);
  Future<String> deleteAllClaimRequests();
}

class ItemWarehouseRemoteDataSourceImpl
    implements ItemWarehouseRemoteDataSource {
  final DioClient _dioClient;

  ItemWarehouseRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ClaimItemResponseModel> createClaimRequest(
    List<ClaimItemRequestModel> claimItems,
  ) async {
    final response = await _dioClient.post(
      '$ApiConstants.clientItemWarehouses$ApiConstants.claimRequest',
      data: claimItems.map((item) => item.toJson()).toList(),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => ClaimItemResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<String> updateClaimRequest(int itemID, int newQuantity) async {
    final response = await _dioClient.patch(
      '$ApiConstants.clientItemWarehouses$ApiConstants.claimRequest',
      data: {'itemID': itemID, 'newQuantity': newQuantity},
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => data.toString(),
    );

    return result.message;
  }

  @override
  Future<OldStockResponseModel> getOldStock(OldStockQuery query) async {
    final response = await _dioClient.get(
      '$ApiConstants.clientItemWarehouses$ApiConstants.oldStock',
      queryParameters: query.toQueryParams(),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => OldStockResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<GetClaimRequestsResponseModel> getClaimRequests() async {
    final response = await _dioClient.get(
      '${ApiConstants.clientItemWarehouses}${ApiConstants.claimRequest}',
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) =>
          GetClaimRequestsResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<String> deleteClaimRequest(int itemID) async {
    final response = await _dioClient.delete(
      '${ApiConstants.clientItemWarehouses}${ApiConstants.claimRequest}/$itemID',
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => data.toString(),
    );

    return result.message;
  }

  @override
  Future<String> deleteAllClaimRequests() async {
    final response = await _dioClient.delete(
      '${ApiConstants.clientItemWarehouses}${ApiConstants.claimRequest}',
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => data.toString(),
    );

    return result.message;
  }
}
