import 'package:trao_doi_do_app/data/models/others_model.dart';
import 'package:trao_doi_do_app/data/models/post_model.dart';

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
}

class PostDetailModel extends PostModel {
  final List<String> tags;
  final List<InterestModel> interests;
  final List<ItemDetailModel> items;

  const PostDetailModel({
    super.id,
    super.authorID,
    super.authorName,
    required super.title,
    required super.description,
    required super.info,
    required super.type,
    super.categoryID,
    super.slug,
    super.status,
    super.images,
    super.newItems,
    super.oldItems,
    super.interestCount,
    super.itemCount,
    super.createdAt,
    this.tags = const [],
    this.interests = const [],
    this.items = const [],
  });

  factory PostDetailModel.fromJson(Map<String, dynamic> json) {
    return PostDetailModel(
      id: json['id'],
      authorID: json['authorID'],
      authorName: json['authorName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      info: json['info'] ?? '{}',
      type: json['type'] ?? 1,
      categoryID: json['categoryID'],
      slug: json['slug'] ?? '',
      status: json['status'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      newItems: [], // For detail, we use items array instead
      oldItems: [], // For detail, we use items array instead
      interestCount: json['interestCount'],
      itemCount: json['itemCount'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      interests:
          json['interests'] != null
              ? (json['interests'] as List)
                  .map(
                    (interest) => InterestModel.fromJson(
                      interest as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : [],
      items:
          json['items'] != null
              ? (json['items'] as List)
                  .map(
                    (item) =>
                        ItemDetailModel.fromJson(item as Map<String, dynamic>),
                  )
                  .toList()
              : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'tags': tags,
      'interests': interests.map((interest) => interest.toJson()).toList(),
      'items': items.map((item) => item.toJson()).toList(),
    });
    return json;
  }
}
