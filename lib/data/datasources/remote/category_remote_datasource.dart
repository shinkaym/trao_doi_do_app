import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/categories_response_model.dart';

abstract class CategoryRemoteDataSource {
  Future<ApiResponseModel<CategoriesResponseModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient _dioClient;

  CategoryRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ApiResponseModel<CategoriesResponseModel>> getCategories() async {
    final response = await _dioClient.get(
      ApiConstants.categories,
      options: Options(extra: {'requiresAuth': false}),
    );

    return ApiResponseModel<CategoriesResponseModel>.fromJson(
      response.data,
      (json) => CategoriesResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return CategoryRemoteDataSourceImpl(dioClient);
});
