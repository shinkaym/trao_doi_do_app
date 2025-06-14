import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/params/posts_query.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository _repository;

  GetPostsUseCase(this._repository);

  Future<Either<Failure, PostsResult>> call(PostsQuery query) async {
    return await _repository.getPosts(query);
  }
}
