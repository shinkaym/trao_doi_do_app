import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/item_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource _remoteDataSource;

  ItemRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ItemsResponse>> getItems({
    int page = 1,
    int limit = 10,
    String? sort,
    String? order,
    String? searchBy,
    String? searchValue,
  }) async {
    try {
      final result = await _remoteDataSource.getItems(
        page: page,
        limit: limit,
        sort: sort,
        order: order,
        searchBy: searchBy,
        searchValue: searchValue,
      );

      return Right(
        ItemsResponse(items: result.items, totalPage: result.totalPage),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định'));
    }
  }
}

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final remoteDataSource = ref.watch(itemRemoteDataSourceProvider);
  return ItemRepositoryImpl(remoteDataSource);
});
