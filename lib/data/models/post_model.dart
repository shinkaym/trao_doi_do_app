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
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
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
      case 4: // freePost - has images (changed from 5 to 4)
        json['images'] = images;
        break;
    }

    return json;
  }
}
