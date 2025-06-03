import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/item_model.dart';

abstract class ItemRemoteDataSource {
  Future<ItemsResponseModel> getItems({
    int page = 1,
    int limit = 10,
    String? sort,
    String? order,
    String? searchBy,
    String? searchValue,
  });
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final DioClient _dioClient;

  ItemRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ItemsResponseModel> getItems({
    int page = 1,
    int limit = 10,
    String? sort,
    String? order,
    String? searchBy,
    String? searchValue,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

    if (sort != null && sort.isNotEmpty) {
      queryParameters['sort'] = sort;
    }

    if (order != null && order.isNotEmpty) {
      queryParameters['order'] = order;
    }

    if (searchBy != null && searchBy.isNotEmpty) {
      queryParameters['searchBy'] = searchBy;
    }

    if (searchValue != null && searchValue.isNotEmpty) {
      queryParameters['searchValue'] = searchValue;
    }

    final response = await _dioClient.get(
      ApiConstants.items,
      queryParameters: queryParameters,
    );

    final apiResponse = ApiResponseModel.fromJson(
      response.data,
      (data) => ItemsResponseModel.fromJson(data as Map<String, dynamic>),
    );

    return apiResponse.data ?? ItemsResponseModel(items: [], totalPage: 0);
  }
}

final itemRemoteDataSourceProvider = Provider<ItemRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ItemRemoteDataSourceImpl(dioClient);
});
