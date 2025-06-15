// File: /lib/data/models/response/post_response_model.dart

import 'package:trao_doi_do_app/data/models/post_model.dart';
import 'package:trao_doi_do_app/domain/entities/response/post_response.dart';

class PostsResponseModel {
  final List<PostModel> posts;
  final int totalPage;

  const PostsResponseModel({required this.posts, required this.totalPage});

  factory PostsResponseModel.fromJson(Map<String, dynamic> json) {
    return PostsResponseModel(
      posts:
          (json['posts'] as List<dynamic>)
              .map((post) => PostModel.fromJson(post as Map<String, dynamic>))
              .toList(),
      totalPage: json['totalPage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.map((post) => post.toJson()).toList(),
      'totalPage': totalPage,
    };
  }

  PostsResponse toEntity() {
    return PostsResponse(
      posts: posts.map((post) => post.toEntity()).toList(),
      totalPage: totalPage,
    );
  }

  factory PostsResponseModel.fromEntity(PostsResponse entity) {
    return PostsResponseModel(
      posts: entity.posts.map((post) => PostModel.fromEntity(post)).toList(),
      totalPage: entity.totalPage,
    );
  }
}

class PostDetailResponseModel {
  final PostDetailModel post;

  const PostDetailResponseModel({required this.post});

  factory PostDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return PostDetailResponseModel(
      post: PostDetailModel.fromJson(json['post'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'post': post.toJson()};
  }

  PostDetailResponse toEntity() {
    return PostDetailResponse(post: post.toEntity());
  }

  factory PostDetailResponseModel.fromEntity(PostDetailResponse entity) {
    return PostDetailResponseModel(post: entity.post as PostDetailModel);
  }
}
