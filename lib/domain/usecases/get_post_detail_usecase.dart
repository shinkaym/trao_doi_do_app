import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/models/response/post_response_model.dart';
import 'package:trao_doi_do_app/data/repositories_impl/post_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';

class GetPostDetailUseCase {
  final PostRepository _repository;

  GetPostDetailUseCase(this._repository);

  Future<Either<Failure, PostDetailModel>> call(String slug) async {
    return await _repository.getPostBySlug(slug);
  }
}

final getPostDetailUseCaseProvider = Provider<GetPostDetailUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return GetPostDetailUseCase(repository);
});
