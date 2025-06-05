import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/item.dart';
import 'package:trao_doi_do_app/domain/entities/params/items_query.dart';

class ItemsResult {
  final List<Item> items;
  final int totalPage;

  const ItemsResult({required this.items, required this.totalPage});
}

abstract class ItemRepository {
  Future<Either<Failure, ItemsResult>> getItems(ItemsQuery query);
}
