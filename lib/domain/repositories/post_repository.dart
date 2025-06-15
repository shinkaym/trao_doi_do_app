import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/entities/response/post_response.dart';
import 'package:trao_doi_do_app/domain/usecases/params/posts_query.dart';

abstract class PostRepository {
  Future<Either<Failure, String>> createPost(Post post);
  Future<Either<Failure, PostsResponse>> getPosts(PostsQuery query);
  Future<Either<Failure, PostDetailResponse>> getPostBySlug(String slug);
}
