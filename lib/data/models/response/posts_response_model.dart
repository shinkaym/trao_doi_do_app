import 'package:trao_doi_do_app/data/models/post_model.dart';

class PostsResponseModel {
  final List<PostModel> posts;
  final int totalPage;

  const PostsResponseModel({required this.posts, required this.totalPage});

  factory PostsResponseModel.fromJson(Map<String, dynamic> json) {
    // Không cần truy cập json['data'] nữa vì ApiResponseModel đã xử lý
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
}
