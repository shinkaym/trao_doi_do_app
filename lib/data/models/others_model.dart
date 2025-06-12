// detail post
class InterestModel {
  final int id;
  final int userID;
  final String userName;
  final String userAvatar;
  final DateTime? createdAt;

  const InterestModel({
    required this.id,
    required this.userID,
    required this.userName,
    required this.userAvatar,
    this.createdAt,
  });

  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id'] ?? 0,
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userID': userID,
      'userName': userName,
      'userAvatar': userAvatar,
      'createdAt': createdAt?.toIso8601String(),
    };
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
      itemID: json['itemID'] ?? 0,
      categoryID: json['categoryID'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      currentQuantity: json['currentQuantity'] ?? 0,
      image: json['image'] ?? '',
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
