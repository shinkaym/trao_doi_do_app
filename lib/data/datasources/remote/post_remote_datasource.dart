import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/post_model.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/post_response_model.dart';
import 'package:trao_doi_do_app/domain/entities/params/posts_query.dart';

abstract class PostRemoteDataSource {
  Future<ApiResponseModel<void>> createPost(PostModel post);
  Future<ApiResponseModel<PostsResponseModel>> getPosts(PostsQuery query);
  Future<ApiResponseModel<PostDetailResponseModel>> getPostBySlug(String slug);
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
    final params = query.toQueryParams();
    print('📥 Params gửi đi: $params');

    final response = await _dioClient.get(
      ApiConstants.clientPosts,
      queryParameters: params,
      options: Options(extra: {'requiresAuth': false}),
    );

    // ✅ In toàn bộ response JSON raw
    print(
      '📥 JSON nhận về:\n${const JsonEncoder.withIndent('  ').convert(response.data)}',
    );

    return ApiResponseModel<PostsResponseModel>.fromJson(
      response.data,
      (json) => PostsResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponseModel<PostDetailResponseModel>> getPostBySlug(
    String slug,
  ) async {
    print('📥 Getting post by slug: $slug');

    final response = await _dioClient.get(
      '${ApiConstants.posts}/slug/$slug',
      options: Options(extra: {'requiresAuth': false}),
    );

    // ✅ In toàn bộ response JSON raw
    print(
      '📥 Post detail JSON:\n${const JsonEncoder.withIndent('  ').convert(response.data)}',
    );

    return ApiResponseModel<PostDetailResponseModel>.fromJson(
      response.data,
      (json) => PostDetailResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
