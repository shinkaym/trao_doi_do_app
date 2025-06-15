import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/item_response.dart';
import 'package:trao_doi_do_app/domain/usecases/params/item_query.dart';

abstract class ItemRepository {
  Future<Either<Failure, ItemsResponse>> getItems(ItemsQuery query);
}
