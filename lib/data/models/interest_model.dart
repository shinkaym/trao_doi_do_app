import 'package:trao_doi_do_app/domain/entities/interest.dart';

class InterestModel {
  final int id;
  final int postID;
  final int userID;
  final String userName;
  final String userAvatar;
  final int status;
  final String createdAt;

  const InterestModel({
    required this.id,
    required this.postID,
    required this.userID,
    required this.userName,
    required this.userAvatar,
    required this.status,
    required this.createdAt,
  });

  // Từ JSON API response
  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id'] ?? 0,
      postID: json['postID'] ?? 0,
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }

  // Chuyển sang JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postID': postID,
      'userID': userID,
      'userName': userName,
      'userAvatar': userAvatar,
      'status': status,
      'createdAt': createdAt,
    };
  }

  // Chuyển đổi sang Domain Entity
  Interest toEntity() {
    return Interest(
      id: id,
      postID: postID,
      userID: userID,
      userName: userName,
      userAvatar: userAvatar,
      status: status,
      createdAt: createdAt,
    );
  }

  // Tạo Model từ Domain Entity
  factory InterestModel.fromEntity(Interest entity) {
    return InterestModel(
      id: entity.id,
      postID: entity.postID,
      userID: entity.userID,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }
}

class InterestPostModel {
  final int id;
  final String slug;
  final String title;
  final String description;
  final String updatedAt;
  final int authorID;
  final String authorName;
  final String authorAvatar;
  final int type;
  final List<InterestModel> interests;
  final List<InterestItemModel> items;

  const InterestPostModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.updatedAt,
    required this.authorID,
    required this.authorName,
    required this.authorAvatar,
    required this.type,
    required this.interests,
    required this.items,
  });

  // Từ JSON API response
  factory InterestPostModel.fromJson(Map<String, dynamic> json) {
    return InterestPostModel(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      authorID: json['authorID'] ?? 0,
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
      type: json['type'] ?? 0,
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
                    (item) => InterestItemModel.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : [],
    );
  }

  // Chuyển sang JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'authorID': authorID,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'description': description,
      'updatedAt': updatedAt,
      'type': type,
      'interests': interests.map((interest) => interest.toJson()).toList(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Chuyển đổi sang Domain Entity
  InterestPost toEntity() {
    return InterestPost(
      id: id,
      slug: slug,
      title: title,
      description: description,
      updatedAt: updatedAt,
      authorID: authorID,
      authorName: authorName,
      authorAvatar: authorAvatar,
      type: type,
      interests: interests.map((interest) => interest.toEntity()).toList(),
      items: items.map((item) => item.toEntity()).toList(),
    );
  }

  // Tạo Model từ Domain Entity
  factory InterestPostModel.fromEntity(InterestPost entity) {
    return InterestPostModel(
      id: entity.id,
      slug: entity.slug,
      title: entity.title,
      description: entity.description,
      updatedAt: entity.updatedAt,
      authorID: entity.authorID,
      authorName: entity.authorName,
      authorAvatar: entity.authorAvatar,
      type: entity.type,
      interests:
          entity.interests
              .map((interest) => InterestModel.fromEntity(interest))
              .toList(),
      items:
          entity.items
              .map((item) => InterestItemModel.fromEntity(item))
              .toList(),
    );
  }
}

class InterestItemModel {
  final int id;
  final int itemID;
  final String name;
  final String categoryName;
  final String image;
  final int quantity;
  final int currentQuantity;

  const InterestItemModel({
    required this.id,
    required this.itemID,
    required this.name,
    required this.categoryName,
    required this.image,
    required this.quantity,
    required this.currentQuantity,
  });

  // Từ JSON API response
  factory InterestItemModel.fromJson(Map<String, dynamic> json) {
    return InterestItemModel(
      id: json['id'] ?? 0,
      itemID: json['itemID'] ?? 0,
      name: json['name'] ?? '',
      categoryName: json['categoryName'] ?? '',
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 0,
      currentQuantity: json['currentQuantity'] ?? 0,
    );
  }

  // Chuyển sang JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemID': itemID,
      'name': name,
      'categoryName': categoryName,
      'image': image,
      'quantity': quantity,
      'currentQuantity': currentQuantity,
    };
  }

  // Chuyển đổi sang Domain Entity
  InterestItem toEntity() {
    return InterestItem(
      id: id,
      itemID: itemID,
      name: name,
      categoryName: categoryName,
      image: image,
      quantity: quantity,
      currentQuantity: currentQuantity,
    );
  }

  // Tạo Model từ Domain Entity
  factory InterestItemModel.fromEntity(InterestItem entity) {
    return InterestItemModel(
      id: entity.id,
      itemID: entity.itemID,
      name: entity.name,
      categoryName: entity.categoryName,
      image: entity.image,
      quantity: entity.quantity,
      currentQuantity: entity.currentQuantity,
    );
  }
}
