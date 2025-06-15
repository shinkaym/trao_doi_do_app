import 'package:dio/dio.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/post_model.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/post_response_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/posts_query.dart';

abstract class PostRemoteDataSource {
  Future<ApiResponseModel<String>> createPost(PostModel post);
  Future<ApiResponseModel<PostsResponseModel>> getPosts(PostsQuery query);
  Future<ApiResponseModel<PostDetailResponseModel>> getPostBySlug(String slug);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient _dioClient;

  PostRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ApiResponseModel<String>> createPost(PostModel post) async {
    final response = await _dioClient.post(
      ApiConstants.posts,
      data: post.toJson(),
    );

    return ApiResponseModel.fromJson(response.data, (data) => data.toString());
  }

  @override
  Future<ApiResponseModel<PostsResponseModel>> getPosts(
    PostsQuery query,
  ) async {
    final response = await _dioClient.get(
      ApiConstants.clientPosts,
      queryParameters: query.toQueryParams(),
      options: Options(extra: {'requiresAuth': false}),
    );

    return ApiResponseModel.fromJson(
      response.data,
      (json) => PostsResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponseModel<PostDetailResponseModel>> getPostBySlug(
    String slug,
  ) async {
    final response = await _dioClient.get(
      '${ApiConstants.posts}/slug/$slug',
      options: Options(extra: {'requiresAuth': false}),
    );

    return ApiResponseModel.fromJson(
      response.data,
      (json) => PostDetailResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
