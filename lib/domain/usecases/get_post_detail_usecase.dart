import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/models/response/post_response_model.dart';
import 'package:trao_doi_do_app/data/repositories_impl/post_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';

class GetPostDetailUseCase {
  final PostRepository _repository;

  GetPostDetailUseCase(this._repository);

  Future<Either<Failure, PostDetailModel>> call(String slug) async {
    if (slug.trim().isEmpty) {
      return const Left(ValidationFailure('Slug không được để trống'));
    }

    return await _repository.getPostBySlug(slug);
  }
}

final getPostDetailUseCaseProvider = Provider<GetPostDetailUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return GetPostDetailUseCase(repository);
});
