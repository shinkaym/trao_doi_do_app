import 'package:dio/dio.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/post_model.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/post_response_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/posts_query.dart';

abstract class PostRemoteDataSource {
  Future<String> createPost(PostModel post);
  Future<PostsResponseModel> getPosts(PostsQuery query);
  Future<PostDetailResponseModel> getPostBySlug(String slug);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient _dioClient;

  PostRemoteDataSourceImpl(this._dioClient);

  @override
  Future<String> createPost(PostModel post) async {
    final response = await _dioClient.post(
      ApiConstants.posts,
      data: post.toJson(),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => data.toString(),
    );

    return result.data!;
  }

  @override
  Future<PostsResponseModel> getPosts(PostsQuery query) async {
    final response = await _dioClient.get(
      ApiConstants.clientPosts,
      queryParameters: query.toQueryParams(),
      options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => PostsResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<PostDetailResponseModel> getPostBySlug(String slug) async {
    final response = await _dioClient.get(
      '${ApiConstants.posts}/slug/$slug',
      options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => PostDetailResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }
}
