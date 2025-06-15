// File: /lib/data/models/post_model.dart

import 'package:trao_doi_do_app/domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    super.id,
    super.authorID,
    super.authorName,
    super.authorAvatar,
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
    super.tags,
    super.interestCount,
    super.currentItemCount,
    super.itemCount,
    super.createdAt,
  });

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      authorID: post.authorID,
      authorName: post.authorName,
      authorAvatar: post.authorAvatar,
      title: post.title,
      description: post.description,
      info: post.info,
      type: post.type,
      categoryID: post.categoryID,
      slug: post.slug,
      status: post.status,
      images: post.images,
      newItems: post.newItems,
      oldItems: post.oldItems,
      tags: post.tags,
      interestCount: post.interestCount,
      itemCount: post.itemCount,
      currentItemCount: post.currentItemCount,
      createdAt: post.createdAt,
    );
  }

  // Factory constructor từ JSON response
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      authorID: json['authorID'],
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      info: json['info'] ?? '{}',
      type: json['type'] ?? 1,
      categoryID: json['categoryID'],
      slug: json['slug'] ?? '',
      status: json['status'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      newItems:
          json['newItems'] != null
              ? (json['newItems'] as List)
                  .map(
                    (item) => NewItem(
                      categoryID: item['categoryID'] ?? 0,
                      name: item['name'] ?? '',
                      quantity: item['quantity'] ?? 1,
                      image: item['image'] ?? '',
                    ),
                  )
                  .toList()
              : [],
      oldItems:
          json['oldItems'] != null
              ? (json['oldItems'] as List)
                  .map(
                    (item) => OldItem(
                      itemID: item['itemID'] ?? 0,
                      quantity: item['quantity'] ?? 1,
                      image: item['image'] ?? '',
                    ),
                  )
                  .toList()
              : [],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      interestCount: json['interestCount'],
      itemCount: json['itemCount'],
      currentItemCount: json['currentItemCount'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
    );
  }

  Post toEntity() {
    return Post(
      id: id,
      authorID: authorID,
      authorName: authorName,
      authorAvatar: authorAvatar,
      title: title,
      description: description,
      info: info,
      type: type,
      categoryID: categoryID,
      slug: slug,
      status: status,
      images: images,
      newItems: newItems,
      oldItems: oldItems,
      tags: tags,
      interestCount: interestCount,
      itemCount: itemCount,
      currentItemCount: currentItemCount,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'title': title,
      'description': description,
      'type': type,
      'info': info, // Already JSON string
    };

    if (type == 3 && categoryID != null) {
      json['categoryID'] = categoryID;
    }

    // Add type-specific fields
    switch (type) {
      case 1: // giveAway - has newItems and oldItems
      case 2: // foundItem - has newItems and oldItems
        json['newItems'] =
            newItems
                .map(
                  (item) => {
                    'categoryID': item.categoryID,
                    'name': item.name,
                    'quantity': item.quantity,
                    'image': item.image,
                  },
                )
                .toList();

        json['oldItems'] =
            oldItems
                .map(
                  (item) => {
                    'itemID': item.itemID,
                    'quantity': item.quantity,
                    'image': item.image,
                  },
                )
                .toList();
        json['images'] = images;
        break;
      case 3: // findLost - has images
      case 4: // freePost - has images
        json['images'] = images;
        break;
    }

    return json;
  }
}

class PostDetailModel extends PostDetail {
  const PostDetailModel({
    super.id,
    super.authorID,
    super.authorName,
    super.authorAvatar,
    required super.title,
    required super.description,
    required super.info,
    required super.type,
    super.categoryID,
    super.slug,
    super.status,
    super.images = const [],
    super.newItems = const [],
    super.oldItems = const [],
    super.tags = const [],
    super.interestCount,
    super.itemCount,
    super.currentItemCount,
    super.createdAt,
    super.interests = const [],
    super.items = const [],
  });

  factory PostDetailModel.fromJson(Map<String, dynamic> json) {
    return PostDetailModel(
      id: json['id'],
      authorID: json['authorID'],
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
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
      currentItemCount: json['currentItemCount'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      interests:
          json['interests'] != null
              ? (json['interests'] as List)
                  .map(
                    (interest) => PostInterestModel.fromJson(
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

  PostDetail toEntity() {
    return PostDetail(
      id: id,
      authorID: authorID,
      authorName: authorName,
      authorAvatar: authorAvatar,
      title: title,
      description: description,
      info: info,
      type: type,
      categoryID: categoryID,
      slug: slug,
      status: status,
      images: images,
      newItems: newItems,
      oldItems: oldItems,
      tags: tags,
      interestCount: interestCount,
      itemCount: itemCount,
      currentItemCount: currentItemCount,
      createdAt: createdAt,
      interests: interests,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'authorID': authorID,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'title': title,
      'description': description,
      'info': info,
      'type': type,
      'categoryID': categoryID,
      'slug': slug,
      'status': status,
      'images': images,
      'interestCount': interestCount,
      'itemCount': itemCount,
      'currentItemCount': currentItemCount,
      'createdAt': createdAt?.toIso8601String(),
      'tags': tags,
      'interests':
          interests
              .map((interest) => (interest as PostInterestModel).toJson())
              .toList(),
      'items': items.map((item) => (item as ItemDetailModel).toJson()).toList(),
    };
    return json;
  }
}

class PostInterestModel extends PostInterest {
  final int? postID;
  final String? message;

  const PostInterestModel({
    required super.id,
    required super.userID,
    required super.userName,
    required super.userAvatar,
    super.createdAt,
    this.postID,
    this.message,
  });

  factory PostInterestModel.fromJson(Map<String, dynamic> json) {
    return PostInterestModel(
      id: json['id'],
      userID: json['userID'],
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      postID: json['postID'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userID': userID,
      'userName': userName,
      'userAvatar': userAvatar,
      'createdAt': createdAt?.toIso8601String(),
      'postID': postID,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [...super.props, postID, message];
}

class ItemDetailModel extends ItemDetail {
  const ItemDetailModel({
    required super.itemID,
    required super.categoryID,
    required super.categoryName,
    required super.name,
    required super.quantity,
    required super.currentQuantity,
    required super.image,
  });

  factory ItemDetailModel.fromJson(Map<String, dynamic> json) {
    return ItemDetailModel(
      itemID: json['itemID'] as int,
      categoryID: json['categoryID'] as int,
      categoryName: json['categoryName'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      currentQuantity: json['currentQuantity'] as int,
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'categoryID': categoryID,
      'categoryName': categoryName,
      'name': name,
      'quantity': quantity,
      'currentQuantity': currentQuantity,
      'image': image,
    };
  }
}
