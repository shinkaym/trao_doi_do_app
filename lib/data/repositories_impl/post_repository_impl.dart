import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/post_remote_datasource.dart';
import 'package:trao_doi_do_app/data/models/post_model.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/entities/response/post_response.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/params/posts_query.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remoteDataSource;

  PostRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, String>> createPost(Post post) async {
    return handleRepositoryCall<String>(() async {
      final postModel = PostModel.fromEntity(post);
      final result = await _remoteDataSource.createPost(postModel);
      return result;
    }, 'Lỗi tạo bài đăng');
  }

  @override
  Future<Either<Failure, PostsResponse>> getPosts(PostsQuery query) async {
    return handleRepositoryCall<PostsResponse>(() async {
      final remoteResponse = await _remoteDataSource.getPosts(query);
      final postsEntity = remoteResponse.toEntity();
      return postsEntity;
    }, 'Lỗi tải danh sách bài đăng');
  }

  @override
  Future<Either<Failure, PostDetailResponse>> getPostBySlug(String slug) async {
    return handleRepositoryCall<PostDetailResponse>(() async {
      final remoteResponse = await _remoteDataSource.getPostBySlug(slug);
      final postDetailEntity = remoteResponse.toEntity();
      return postDetailEntity;
    }, 'Lỗi tải chi tiết bài đăng');
  }
}
