import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/local/category_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/category_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, CategoriesResult>> getCategories() async {
    try {
      final apiResponse = await _remoteDataSource.getCategories();

      if (apiResponse.code >= 200 &&
          apiResponse.code < 300 &&
          apiResponse.data != null) {
        final categoriesData = apiResponse.data!;

        // Cache to local storage
        await _localDataSource.cacheCategories(categoriesData.categories);

        final result = CategoriesResult(categories: categoriesData.categories);

        return Right(result);
      } else {
        // If remote fails, try to get from cache
        try {
          final cachedCategories = await _localDataSource.getCachedCategories();
          if (cachedCategories.isNotEmpty) {
            final result = CategoriesResult(categories: cachedCategories);
            return Right(result);
          }
          return Left(
            ServerFailure(
              apiResponse.message.isNotEmpty
                  ? apiResponse.message
                  : 'Lỗi không xác định khi tải danh sách categories',
              apiResponse.code,
            ),
          );
        } on CacheException catch (_) {
          return Left(
            ServerFailure(
              apiResponse.message.isNotEmpty
                  ? apiResponse.message
                  : 'Lỗi không xác định khi tải danh sách categories',
              apiResponse.code,
            ),
          );
        }
      }
    } on ServerException catch (e) {
      // If remote fails, try to get from cache
      try {
        final cachedCategories = await _localDataSource.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          final result = CategoriesResult(categories: cachedCategories);
          return Right(result);
        }
        return Left(ServerFailure(e.message, e.statusCode));
      } on CacheException catch (_) {
        return Left(ServerFailure(e.message, e.statusCode));
      }
    } on NetworkException catch (e) {
      // Network error, try cache
      try {
        final cachedCategories = await _localDataSource.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          final result = CategoriesResult(categories: cachedCategories);
          return Right(result);
        }
        return Left(NetworkFailure(e.message));
      } on CacheException {
        return Left(NetworkFailure(e.message));
      }
    } catch (e) {
      return Left(
        ServerFailure('Lỗi không xác định khi tải danh sách categories'),
      );
    }
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  final localDataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource, localDataSource);
});
