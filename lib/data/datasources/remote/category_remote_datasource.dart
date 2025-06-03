import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient _dioClient;

  CategoryRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dioClient.get(ApiConstants.categories);

      final apiResponse = ApiResponseModel<List<CategoryModel>>.fromJson(
        response.data,
        (data) {
          final categoriesJson = (data as Map<String, dynamic>)['categories'] as List<dynamic>;
          return categoriesJson.map((e) => CategoryModel.fromJson(e)).toList();
        },
      );

      return apiResponse.data ?? [];
    } catch (e) {
      // Ghi log hoặc throw Failure ở đây nếu cần
      print('CategoryRemoteDataSource error: $e');
      rethrow;
    }
  }
}

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CategoryRemoteDataSourceImpl(dioClient);
});
