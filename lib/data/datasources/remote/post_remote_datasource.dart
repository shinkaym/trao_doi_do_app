import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/post_model.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/posts_response_model.dart';
import 'package:trao_doi_do_app/domain/entities/params/posts_query.dart';

abstract class PostRemoteDataSource {
  Future<ApiResponseModel<void>> createPost(PostModel post);
  Future<ApiResponseModel<PostsResponseModel>> getPosts(PostsQuery query);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient _dioClient;

  PostRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ApiResponseModel<void>> createPost(PostModel post) async {
    final body = post.toJson();
    // ✅ Hiển thị body dạng JSON có format
    print(
      '📤 JSON gửi lên:\n${const JsonEncoder.withIndent('  ').convert(body)}',
    );

    final response = await _dioClient.post(ApiConstants.posts, data: body);

    return ApiResponseModel<void>.fromJson(response.data, null);
  }

  @override
  Future<ApiResponseModel<PostsResponseModel>> getPosts(
    PostsQuery query,
  ) async {
    final response = await _dioClient.get(
      ApiConstants.clientPosts,
      queryParameters: query.toQueryParams(),
    );

    return ApiResponseModel<PostsResponseModel>.fromJson(
      response.data,
      (json) => PostsResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PostRemoteDataSourceImpl(dioClient);
});
