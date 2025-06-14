import 'package:dio/dio.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/item_response_model.dart';
import 'package:trao_doi_do_app/domain/entities/params/items_query.dart';

abstract class ItemRemoteDataSource {
  Future<ApiResponseModel<ItemsResponseModel>> getItems(ItemsQuery query);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final DioClient _dioClient;

  ItemRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ApiResponseModel<ItemsResponseModel>> getItems(
    ItemsQuery query,
  ) async {
    final response = await _dioClient.get(
      ApiConstants.items,
      queryParameters: query.toQueryParams(),
      options: Options(extra: {'requiresAuth': false}),
    );

    return ApiResponseModel<ItemsResponseModel>.fromJson(
      response.data,
      (json) => ItemsResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
