import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int? id;
  final int authorID;
  final String title;
  final String info; // JSON string
  final int type; // 1: giveAway, 2: foundItem, 3: findLost, 4: freePost
  final List<String> images; // Base64 strings, only for type 2,3,4
  final List<NewItem> newItems; // Only for type 1
  final List<OldItem> oldItems; // Only for type 1
  final DateTime? createdAt;

  const Post({
    this.id,
    required this.authorID,
    required this.title,
    required this.info,
    required this.type,
    this.images = const [],
    this.newItems = const [],
    this.oldItems = const [],
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    authorID,
    title,
    info,
    type,
    images,
    newItems,
    oldItems,
    createdAt,
  ];
}

class NewItem extends Equatable {
  final int categoryID;
  final String categoryName;
  final String name;
  final int quantity;

  const NewItem({
    required this.categoryID,
    required this.categoryName,
    required this.name,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [categoryID, categoryName, name, quantity];
}

class OldItem extends Equatable {
  final int itemID; // Changed from itemId to itemID
  final String categoryName;
  final int quantity;

  const OldItem({
    required this.itemID,
    required this.categoryName,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [itemID, categoryName, quantity];
}

// Helper classes for different post types info
class GiveAwayInfo {
  final String description;

  GiveAwayInfo({required this.description});

  Map<String, dynamic> toJson() => {'description': description};

  factory GiveAwayInfo.fromJson(Map<String, dynamic> json) =>
      GiveAwayInfo(description: json['description'] ?? '');
}

class FoundItemInfo {
  final String description;
  final String foundLocation;
  final String foundDate;
  final int categoryID;

  FoundItemInfo({
    required this.description,
    required this.foundLocation,
    required this.foundDate,
    required this.categoryID,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'foundLocation': foundLocation,
    'foundDate': foundDate,
    'categoryID': categoryID,
  };

  factory FoundItemInfo.fromJson(Map<String, dynamic> json) => FoundItemInfo(
    description: json['description'] ?? '',
    foundLocation: json['foundLocation'] ?? '',
    foundDate: json['foundDate'] ?? '',
    categoryID: json['categoryID'] ?? 0,
  );
}

class FindLostInfo {
  final String description;
  final String lostLocation;
  final String lostDate;
  final int categoryID;
  final String reward;

  FindLostInfo({
    required this.description,
    required this.lostLocation,
    required this.lostDate,
    required this.categoryID,
    required this.reward,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'lostLocation': lostLocation,
    'lostDate': lostDate,
    'categoryID': categoryID,
    'reward': reward,
  };

  factory FindLostInfo.fromJson(Map<String, dynamic> json) => FindLostInfo(
    description: json['description'] ?? '',
    lostLocation: json['lostLocation'] ?? '',
    lostDate: json['lostDate'] ?? '',
    categoryID: json['categoryID'] ?? 0,
    reward: json['reward'] ?? '',
  );
}

class FreePostInfo {
  final String description;

  FreePostInfo({required this.description});

  Map<String, dynamic> toJson() => {'description': description};

  factory FreePostInfo.fromJson(Map<String, dynamic> json) =>
      FreePostInfo(description: json['description'] ?? '');
}
