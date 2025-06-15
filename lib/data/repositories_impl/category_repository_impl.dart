import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/local/category_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/category_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/response/category_response.dart';
import 'package:trao_doi_do_app/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, CategoriesResponse>> getCategories() async {
    return handleRepositoryCall<CategoriesResponse>(
      () async {
        try {
          // Try to get from remote first
          final remoteResponse = await _remoteDataSource.getCategories();
          final categoriesEntity = remoteResponse.toEntity();
          
          // Cache the categories silently (don't let cache failures affect the result)
          await silentCall(() async {
            await _localDataSource.cacheCategories(remoteResponse.categories);
          });
          
          return categoriesEntity;
        } catch (e) {
          // If remote fails, try to get from cache
          final cachedCategories = await _localDataSource.getCachedCategories();
          if (cachedCategories.isNotEmpty) {
            return CategoriesResponse(
              categories: cachedCategories.map((model) => model.toEntity()).toList(),
            );
          }
          
          // If both remote and cache fail, rethrow the original exception
          rethrow;
        }
      },
      'Lỗi khi tải danh sách categories',
    );
  }
}