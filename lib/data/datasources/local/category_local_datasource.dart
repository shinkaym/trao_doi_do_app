import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCachedCategories();
  Future<void> cacheCategories(List<CategoryModel> categories);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  static const String _boxName = StorageKeys.categories;

  @override
  Future<List<CategoryModel>> getCachedCategories() async {
    try {
      // Mở box không chỉ định kiểu cụ thể để linh hoạt hơn
      final box = await Hive.openBox(_boxName);
      final dynamic cachedData = box.get(StorageKeys.categories);

      if (cachedData == null) {
        throw const CacheException('No cached categories found');
      }

      // Kiểm tra và ép kiểu an toàn
      List<Map<String, dynamic>> jsonList;
      if (cachedData is List) {
        jsonList = cachedData.cast<Map<String, dynamic>>();
      } else {
        throw const CacheException('Invalid cached data format');
      }

      if (jsonList.isEmpty) {
        throw const CacheException('No cached categories found');
      }

      // Chuyển đổi từ JSON sang CategoryModel
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to get cached categories: $e');
    }
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    try {
      // Mở box không chỉ định kiểu
      final box = await Hive.openBox(_boxName);

      // Chuyển đổi CategoryModel sang JSON
      final jsonList = categories.map((category) => category.toJson()).toList();

      // Lưu vào Hive box
      await box.put(StorageKeys.categories, jsonList);
    } catch (e) {
      throw CacheException('Failed to cache categories: $e');
    }
  }
}

// Provider để cung cấp CategoryLocalDataSource
final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((
  ref,
) {
  return CategoryLocalDataSourceImpl();
});
