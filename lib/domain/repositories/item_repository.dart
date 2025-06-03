import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/item.dart';

class ItemsResponse {
  final List<Item> items;
  final int totalPage;

  ItemsResponse({required this.items, required this.totalPage});
}

abstract class ItemRepository {
  Future<Either<Failure, ItemsResponse>> getItems({
    int page = 1,
    int limit = 10,
    String? sort,
    String? order,
    String? searchBy,
    String? searchValue,
  });
}
