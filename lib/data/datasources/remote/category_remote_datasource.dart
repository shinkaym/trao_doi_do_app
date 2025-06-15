import 'package:dio/dio.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/category_response_model.dart';

abstract class CategoryRemoteDataSource {
  Future<CategoriesResponseModel> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient _dioClient;

  CategoryRemoteDataSourceImpl(this._dioClient);

  @override
  Future<CategoriesResponseModel> getCategories() async {
    final response = await _dioClient.get(
      ApiConstants.categories,
      options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => CategoriesResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }
}
