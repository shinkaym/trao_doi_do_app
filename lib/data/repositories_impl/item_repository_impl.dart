import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/item_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/response/item_response.dart';
import 'package:trao_doi_do_app/domain/repositories/item_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/params/items_query.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource _remoteDataSource;

  ItemRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ItemsResponse>> getItems(ItemsQuery query) async {
    return handleRepositoryCall<ItemsResponse>(() async {
      final remoteResponse = await _remoteDataSource.getItems(query);
      final itemEntity = remoteResponse.toEntity();

      return itemEntity;
    });
  }
}
