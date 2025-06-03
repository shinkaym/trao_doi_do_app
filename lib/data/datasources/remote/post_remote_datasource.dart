import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<void> createPost(PostModel post);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient _dioClient;

  PostRemoteDataSourceImpl(this._dioClient);

  @override
  Future<void> createPost(PostModel post) async {
    final body = post.toJson();

    // ✅ Hiển thị body dạng JSON có format
    print(
      '📤 JSON gửi lên:\n${const JsonEncoder.withIndent('  ').convert(body)}',
    );
    await _dioClient.post(ApiConstants.posts, data: post.toJson());
  }
}

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PostRemoteDataSourceImpl(dioClient);
});
