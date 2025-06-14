import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/item_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/params/items_query.dart';
import 'package:trao_doi_do_app/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource _remoteDataSource;

  ItemRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ItemsResult>> getItems(ItemsQuery query) async {
    try {
      final apiResponse = await _remoteDataSource.getItems(query);

      if (apiResponse.code >= 200 &&
          apiResponse.code < 300 &&
          apiResponse.data != null) {
        final itemsData = apiResponse.data!;

        final result = ItemsResult(
          items: itemsData.items,
          totalPage: itemsData.totalPage,
        );

        return Right(result);
      } else {
        return Left(
          ServerFailure(
            apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'Lỗi không xác định khi tải danh sách items',
            apiResponse.code,
          ),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi tải danh sách items'));
    }
  }
}
