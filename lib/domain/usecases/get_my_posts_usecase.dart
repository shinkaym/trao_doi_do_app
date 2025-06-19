import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/post_response.dart';
import 'package:trao_doi_do_app/domain/usecases/params/post_query.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';

class GetMyPostsUseCase {
  final PostRepository _repository;

  GetMyPostsUseCase(this._repository);

  Future<Either<Failure, PostsResponse>> call(PostsQuery query) async {
    return await _repository.myPosts(query);
  }
}
