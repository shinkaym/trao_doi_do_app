import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int? id;
  final int? authorID;
  final String? authorName;
  final String? authorAvatar;
  final String title;
  final String description;
  final String info; // JSON string
  final int type; // 1: giveAway, 2: foundItem, 3: findLost, 4: freePost
  final int? categoryID;
  final String? slug;
  final int? status; // 1: Pending, 2: Rejected, 3: Approved
  final List<String> images; // Base64 strings
  final List<NewItem> newItems; // for type 1, 2
  final List<OldItem> oldItems; // for type 1, 2
  final List<String> tags;
  final int? interestCount;
  final int? itemCount;
  final int? currentItemCount;
  final DateTime? createdAt;

  const Post({
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

  @override
  List<Object?> get props => [
    id,
    authorID,
    authorName,
    authorAvatar,
    title,
    description,
    info,
    type,
    categoryID,
    slug,
    status,
    images,
    newItems,
    oldItems,
    tags,
    interestCount,
    itemCount,
    currentItemCount,
    createdAt,
  ];
}

class PostDetail extends Post {
  final List<PostInterest> interests;
  final List<ItemDetail> items;

  const PostDetail({
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
    this.interests = const [],
    this.items = const [],
  });

  @override
  List<Object?> get props => [...super.props, interests, items];
}

class PostInterest extends Equatable {
  final int id;
  final int userID;
  final String userName;
  final String userAvatar;
  final DateTime? createdAt;

  const PostInterest({
    required this.id,
    required this.userID,
    required this.userName,
    required this.userAvatar,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, userID, userName, userAvatar, createdAt];
}

class ItemDetail extends Equatable {
  final int itemID;
  final int categoryID;
  final String categoryName;
  final String name;
  final int quantity;
  final int currentQuantity;
  final String image;

  const ItemDetail({
    required this.itemID,
    required this.categoryID,
    required this.categoryName,
    required this.name,
    required this.quantity,
    required this.currentQuantity,
    required this.image,
  });

  @override
  List<Object?> get props => [
    itemID,
    categoryID,
    categoryName,
    name,
    quantity,
    currentQuantity,
    image,
  ];
}

class NewItem extends Equatable {
  final int categoryID;
  final String name;
  final int quantity;
  final String image;

  const NewItem({
    required this.categoryID,
    required this.name,
    this.quantity = 1,
    required this.image,
  });

  @override
  List<Object?> get props => [categoryID, name, quantity, image];
}

class OldItem extends Equatable {
  final int itemID;
  final int quantity;
  final String image;

  const OldItem({required this.itemID, this.quantity = 1, required this.image});

  @override
  List<Object?> get props => [itemID, quantity, image];
}

class FoundItemInfo {
  final String foundLocation;
  final String foundDate;

  FoundItemInfo({required this.foundLocation, required this.foundDate});

  Map<String, dynamic> toJson() => {
    'foundLocation': foundLocation,
    'foundDate': foundDate,
  };

  factory FoundItemInfo.fromJson(Map<String, dynamic> json) => FoundItemInfo(
    foundLocation: json['foundLocation'] ?? '',
    foundDate: json['foundDate'] ?? '',
  );
}

class FindLostInfo {
  final String lostLocation;
  final String lostDate;
  final String reward;
  final String category;

  FindLostInfo({
    required this.lostLocation,
    required this.lostDate,
    required this.reward,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'lostLocation': lostLocation,
    'lostDate': lostDate,
    'reward': reward,
    'category': category,
  };

  factory FindLostInfo.fromJson(Map<String, dynamic> json) => FindLostInfo(
    lostLocation: json['lostLocation'] ?? '',
    lostDate: json['lostDate'] ?? '',
    reward: json['reward'] ?? '',
    category: json['category'] ?? '',
  );
}
