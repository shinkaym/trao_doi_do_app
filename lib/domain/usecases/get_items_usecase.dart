import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/item_response.dart';
import 'package:trao_doi_do_app/domain/usecases/params/item_query.dart';
import 'package:trao_doi_do_app/domain/repositories/item_repository.dart';

class GetItemsUseCase {
  final ItemRepository _repository;

  GetItemsUseCase(this._repository);

  Future<Either<Failure, ItemsResponse>> call(ItemsQuery query) async {
    return await _repository.getItems(query);
  }
}
