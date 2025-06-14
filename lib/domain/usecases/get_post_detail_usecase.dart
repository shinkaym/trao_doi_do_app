import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/models/response/post_response_model.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';

class GetPostDetailUseCase {
  final PostRepository _repository;

  GetPostDetailUseCase(this._repository);

  Future<Either<Failure, PostDetailModel>> call(String slug) async {
    return await _repository.getPostBySlug(slug);
  }
}
