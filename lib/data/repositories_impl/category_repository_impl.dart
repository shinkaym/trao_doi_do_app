import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/local/category_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/category_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';
import 'package:trao_doi_do_app/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      // Try to get from remote first
      final remoteCategories = await _remoteDataSource.getCategories();

      // Cache to local storage
      await _localDataSource.cacheCategories(remoteCategories);

      return Right(remoteCategories);
    } on ServerException catch (e) {
      // If remote fails, try to get from cache
      try {
        final cachedCategories = await _localDataSource.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          return Right(cachedCategories);
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
          return Right(cachedCategories);
        }
        return Left(NetworkFailure(e.message));
      } on CacheException {
        return Left(NetworkFailure(e.message));
      }
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định'));
    }
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  final localDataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource, localDataSource);
});
