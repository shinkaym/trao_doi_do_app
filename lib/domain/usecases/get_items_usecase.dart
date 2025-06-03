import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/repositories_impl/item_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/item_repository.dart';

class GetItemsUseCase {
  final ItemRepository _repository;

  GetItemsUseCase(this._repository);

  Future<Either<Failure, ItemsResponse>> call({
    int page = 1,
    int limit = 10,
    String? sort,
    String? order,
    String? searchBy,
    String? searchValue,
  }) async {
    return await _repository.getItems(
      page: page,
      limit: limit,
      sort: sort,
      order: order,
      searchBy: searchBy,
      searchValue: searchValue,
    );
  }
}

final getItemsUseCaseProvider = Provider<GetItemsUseCase>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return GetItemsUseCase(repository);
});