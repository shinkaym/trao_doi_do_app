import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/models/response/post_response_model.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/entities/params/posts_query.dart';

class PostsResult {
  final List<Post> posts;
  final int totalPage;

  const PostsResult({required this.posts, required this.totalPage});
}

abstract class PostRepository {
  Future<Either<Failure, void>> createPost(Post post);
  Future<Either<Failure, PostsResult>> getPosts(PostsQuery query);
  Future<Either<Failure, PostDetailModel>> getPostBySlug(String slug);
}
