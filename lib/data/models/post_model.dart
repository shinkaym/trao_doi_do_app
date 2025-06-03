import 'dart:convert';
import 'package:trao_doi_do_app/domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    super.id,
    required super.authorID,
    required super.title,
    required super.info,
    required super.type,
    super.images,
    super.newItems,
    super.oldItems,
    super.createdAt,
  });

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      authorID: post.authorID,
      title: post.title,
      info: post.info,
      type: post.type,
      images: post.images,
      newItems: post.newItems,
      oldItems: post.oldItems,
      createdAt: post.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'authorID': authorID == 0 ? 1 : authorID, // Default to 1 if 0
      'title': title,
      'type': type,
      'info': info, // Already JSON string
    };

    // Add type-specific fields
    switch (type) {
      case 1: // giveAway - has newItems and oldItems
        json['newItems'] =
            newItems
                .map(
                  (item) => {
                    'categoryID': item.categoryID,
                    'categoryName': item.categoryName,
                    'name': item.name,
                    'quantity': item.quantity,
                  },
                )
                .toList();

        json['oldItems'] =
            oldItems
                .map(
                  (item) => {
                    'itemID': item.itemID,
                    'categoryName': item.categoryName,
                    'quantity': item.quantity,
                  },
                )
                .toList();
        break;

      case 2: // foundItem - has images
      case 3: // findLost - has images
      case 4: // freePost - has images
        json['images'] = images;
        break;
    }

    return json;
  }

  // Factory constructor từ JSON response
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      authorID: json['authorID'] ?? 1,
      title: json['title'] ?? '',
      info: json['info'] ?? '{}',
      type: json['type'] ?? 1,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      newItems:
          json['newItems'] != null
              ? (json['newItems'] as List)
                  .map(
                    (item) => NewItem(
                      categoryID: item['categoryID'] ?? 0,
                      categoryName: item['categoryName'] ?? '',
                      name: item['name'] ?? '',
                      quantity: item['quantity'] ?? 1,
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
                      categoryName: item['categoryName'] ?? '',
                      quantity: item['quantity'] ?? 1,
                    ),
                  )
                  .toList()
              : [],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
    );
  }
}
