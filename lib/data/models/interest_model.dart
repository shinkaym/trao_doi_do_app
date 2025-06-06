import 'package:trao_doi_do_app/domain/entities/interest.dart';

class InterestModel extends Interest {
  const InterestModel({
    required super.id,
    required super.postID,
    required super.userID,
    required super.userName,
    required super.userAvatar,
    required super.status,
  });

  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id'] ?? 0,
      postID: json['postID'] ?? 0,
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postID': postID,
      'userID': userID,
      'userName': userName,
      'userAvatar': userAvatar,
      'status': status,
    };
  }
}

class InterestPostModel extends InterestPost {
  const InterestPostModel({
    required super.id,
    required super.slug,
    required super.title,
    required super.type,
    required super.interests,
    required super.items,
  });

  factory InterestPostModel.fromJson(Map<String, dynamic> json) {
    return InterestPostModel(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 0,
      interests: json['interests'] != null
          ? (json['interests'] as List)
              .map((interest) => InterestModel.fromJson(interest as Map<String, dynamic>))
              .cast<Interest>()
              .toList()
          : [],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => InterestItemModel.fromJson(item as Map<String, dynamic>))
              .cast<InterestItem>()
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'type': type,
      'interests': interests.map((interest) => (interest as InterestModel).toJson()).toList(),
      'items': items.map((item) => (item as InterestItemModel).toJson()).toList(),
    };
  }
}

class InterestItemModel extends InterestItem {
  const InterestItemModel({
    required super.id,
    required super.name,
    required super.categoryName,
    required super.image,
    required super.quantity,
  });

  factory InterestItemModel.fromJson(Map<String, dynamic> json) {
    return InterestItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categoryName: json['categoryName'] ?? '',
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryName': categoryName,
      'image': image,
      'quantity': quantity,
    };
  }
}