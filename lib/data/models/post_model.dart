import 'package:trao_doi_do_app/domain/entities/post.dart';

class PostModel {
  final int? id;
  final int? authorID;
  final String? authorName;
  final String? authorAvatar;
  final String title;
  final String description;
  final String info;
  final int type;
  final int? categoryID;
  final String? slug;
  final int? status;
  final List<String> images;
  final List<NewItemModel> newItems;
  final List<OldItemModel> oldItems;
  final List<String> tags;
  final int? interestCount;
  final int? itemCount;
  final int? currentItemCount;
  final DateTime? createdAt;

  const PostModel({
    this.id,
    this.authorID,
    this.authorName,
    this.authorAvatar,
    required this.title,
    required this.description,
    required this.info,
    required this.type,
    this.categoryID,
    this.slug,
    this.status,
    this.images = const [],
    this.newItems = const [],
    this.oldItems = const [],
    this.tags = const [],
    this.interestCount,
    this.itemCount,
    this.currentItemCount,
    this.createdAt,
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
      newItems:
          post.newItems.map((item) => NewItemModel.fromEntity(item)).toList(),
      oldItems:
          post.oldItems.map((item) => OldItemModel.fromEntity(item)).toList(),
      tags: post.tags,
      interestCount: post.interestCount,
      itemCount: post.itemCount,
      currentItemCount: post.currentItemCount,
      createdAt: post.createdAt,
    );
  }

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
                    (item) =>
                        NewItemModel.fromJson(item as Map<String, dynamic>),
                  )
                  .toList()
              : [],
      oldItems:
          json['oldItems'] != null
              ? (json['oldItems'] as List)
                  .map(
                    (item) =>
                        OldItemModel.fromJson(item as Map<String, dynamic>),
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
      newItems: newItems.map((item) => item.toEntity()).toList(),
      oldItems: oldItems.map((item) => item.toEntity()).toList(),
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
      'info': info,
    };

    if (type == 3 && categoryID != null) {
      json['categoryID'] = categoryID;
    }

    switch (type) {
      case 1:
      case 2:
        json['newItems'] = newItems.map((item) => item.toJson()).toList();
        json['oldItems'] = oldItems.map((item) => item.toJson()).toList();
        json['images'] = images;
        break;
      case 3:
      case 4:
        json['images'] = images;
        break;
    }

    return json;
  }
}

class PostDetailModel {
  final int? id;
  final int? authorID;
  final String? authorName;
  final String? authorAvatar;
  final String title;
  final String description;
  final String info;
  final int type;
  final int? categoryID;
  final String? slug;
  final int? status;
  final List<String> images;
  final List<NewItemModel> newItems;
  final List<OldItemModel> oldItems;
  final List<String> tags;
  final int? interestCount;
  final int? itemCount;
  final int? currentItemCount;
  final DateTime? createdAt;
  final List<PostInterestModel> interests;
  final List<ItemDetailModel> items;

  const PostDetailModel({
    this.id,
    this.authorID,
    this.authorName,
    this.authorAvatar,
    required this.title,
    required this.description,
    required this.info,
    required this.type,
    this.categoryID,
    this.slug,
    this.status,
    this.images = const [],
    this.newItems = const [],
    this.oldItems = const [],
    this.tags = const [],
    this.interestCount,
    this.itemCount,
    this.currentItemCount,
    this.createdAt,
    this.interests = const [],
    this.items = const [],
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
      newItems: [],
      oldItems: [],
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
      newItems: newItems.map((item) => item.toEntity()).toList(),
      oldItems: oldItems.map((item) => item.toEntity()).toList(),
      tags: tags,
      interestCount: interestCount,
      itemCount: itemCount,
      currentItemCount: currentItemCount,
      createdAt: createdAt,
      interests: interests.map((interest) => interest.toEntity()).toList(),
      items: items.map((item) => item.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'interests': interests.map((interest) => interest.toJson()).toList(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class PostInterestModel {
  final int id;
  final int userID;
  final String userName;
  final String userAvatar;
  final DateTime? createdAt;
  final int? postID;
  final String? message;

  const PostInterestModel({
    required this.id,
    required this.userID,
    required this.userName,
    required this.userAvatar,
    this.createdAt,
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

  PostInterest toEntity() {
    return PostInterest(
      id: id,
      userID: userID,
      userName: userName,
      userAvatar: userAvatar,
      createdAt: createdAt,
    );
  }

  factory PostInterestModel.fromEntity(PostInterest entity) {
    return PostInterestModel(
      id: entity.id,
      userID: entity.userID,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      createdAt: entity.createdAt,
    );
  }
}

class ItemDetailModel {
  final int itemID;
  final int categoryID;
  final String categoryName;
  final String name;
  final int quantity;
  final int currentQuantity;
  final String image;

  const ItemDetailModel({
    required this.itemID,
    required this.categoryID,
    required this.categoryName,
    required this.name,
    required this.quantity,
    required this.currentQuantity,
    required this.image,
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

  ItemDetail toEntity() {
    return ItemDetail(
      itemID: itemID,
      categoryID: categoryID,
      categoryName: categoryName,
      name: name,
      quantity: quantity,
      currentQuantity: currentQuantity,
      image: image,
    );
  }

  factory ItemDetailModel.fromEntity(ItemDetail entity) {
    return ItemDetailModel(
      itemID: entity.itemID,
      categoryID: entity.categoryID,
      categoryName: entity.categoryName,
      name: entity.name,
      quantity: entity.quantity,
      currentQuantity: entity.currentQuantity,
      image: entity.image,
    );
  }
}

class NewItemModel {
  final int categoryID;
  final String name;
  final int quantity;
  final String image;

  const NewItemModel({
    required this.categoryID,
    required this.name,
    this.quantity = 1,
    required this.image,
  });

  factory NewItemModel.fromJson(Map<String, dynamic> json) {
    return NewItemModel(
      categoryID: json['categoryID'] ?? 0,
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryID': categoryID,
      'name': name,
      'quantity': quantity,
      'image': image,
    };
  }

  NewItem toEntity() {
    return NewItem(
      categoryID: categoryID,
      name: name,
      quantity: quantity,
      image: image,
    );
  }

  factory NewItemModel.fromEntity(NewItem entity) {
    return NewItemModel(
      categoryID: entity.categoryID,
      name: entity.name,
      quantity: entity.quantity,
      image: entity.image,
    );
  }
}

class OldItemModel {
  final int itemID;
  final int quantity;
  final String image;

  const OldItemModel({
    required this.itemID,
    this.quantity = 1,
    required this.image,
  });

  factory OldItemModel.fromJson(Map<String, dynamic> json) {
    return OldItemModel(
      itemID: json['itemID'] ?? 0,
      quantity: json['quantity'] ?? 1,
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'itemID': itemID, 'quantity': quantity, 'image': image};
  }

  OldItem toEntity() {
    return OldItem(itemID: itemID, quantity: quantity, image: image);
  }

  factory OldItemModel.fromEntity(OldItem entity) {
    return OldItemModel(
      itemID: entity.itemID,
      quantity: entity.quantity,
      image: entity.image,
    );
  }
}
