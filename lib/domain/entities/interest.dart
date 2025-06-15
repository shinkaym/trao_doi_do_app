import 'package:equatable/equatable.dart';

class Interest extends Equatable {
  final int id;
  final int postID;
  final int userID;
  final String userName;
  final String userAvatar;
  final String createdAt;
  final int status;

  const Interest({
    required this.id,
    required this.postID,
    required this.userID,
    required this.userName,
    required this.userAvatar,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, postID, userID, userName, userAvatar, status, createdAt];
}

class InterestPost extends Equatable {
  final int id;
  final String slug;
  final String title;
  final int type;
  final String description;
  final String updatedAt;
  final int authorID;
  final String authorName;
  final String authorAvatar;
  final List<Interest> interests;
  final List<InterestItem> items;

  const InterestPost({
    required this.id,
    required this.slug,
    required this.title,
    required this.type,
    required this.description,
    required this.updatedAt,
    required this.authorID,
    required this.authorName,
    required this.authorAvatar,
    required this.interests,
    required this.items,
  });

  @override
  List<Object?> get props => [
    id,
    slug,
    title,
    type,
    description,
    updatedAt,
    authorID,
    authorName,
    authorAvatar,
    interests,
    items,
  ];
}

class InterestItem extends Equatable {
  final int id;
  final int itemID;
  final String name;
  final String categoryName;
  final String image;
  final int quantity;
  final int currentQuantity;

  const InterestItem({
    required this.id,
    required this.itemID,
    required this.name,
    required this.categoryName,
    required this.image,
    required this.quantity,
    required this.currentQuantity,
  });

  @override
  List<Object?> get props => [
    id, 
    itemID, 
    name, 
    categoryName, 
    image, 
    quantity, 
    currentQuantity
  ];
}
class InterestsResult {
  final List<InterestPost> interests;
  final int totalPage;

  const InterestsResult({required this.interests, required this.totalPage});
}

class InterestActionResult extends Equatable {
  final int interestID;
  final String message;

  const InterestActionResult({required this.interestID, required this.message});

  @override
  List<Object?> get props => [interestID, message];
}
