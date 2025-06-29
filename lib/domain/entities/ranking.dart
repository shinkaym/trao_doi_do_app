import 'package:equatable/equatable.dart';

class UserRankingResponse extends Equatable {
  final int totalPage;
  final List<UserRank> userRanks;
  final UserRank yourInfo;
  final int yourRank;

  const UserRankingResponse({
    required this.totalPage,
    required this.userRanks,
    required this.yourInfo,
    required this.yourRank,
  });

  @override
  List<Object?> get props => [totalPage, userRanks, yourInfo, yourRank];
}

class UserRank extends Equatable {
  final List<GoodDeed> goodDeeds;
  final int goodPoint;
  final String major;
  final String userAvatar;
  final int userID;
  final String userName;

  const UserRank({
    required this.goodDeeds,
    required this.goodPoint,
    required this.major,
    required this.userAvatar,
    required this.userID,
    required this.userName,
  });

  @override
  List<Object?> get props => [
    goodDeeds,
    goodPoint,
    major,
    userAvatar,
    userID,
    userName,
  ];
}

class GoodDeed extends Equatable {
  final int goodDeedCount;
  final int goodDeedType;

  const GoodDeed({required this.goodDeedCount, required this.goodDeedType});

  @override
  List<Object?> get props => [goodDeedCount, goodDeedType];
}

class MyGoodDeedsResponse extends Equatable {
  final List<MyGoodDeed> goodDeeds;

  const MyGoodDeedsResponse({required this.goodDeeds});

  @override
  List<Object?> get props => [goodDeeds];
}

class MyGoodDeed extends Equatable {
  final String createdAt;
  final int goodDeedType;
  final int goodPoint;
  final int id;
  final List<GoodDeedItem> items;
  final int transactionID;
  final int userID;
  final String userName;

  const MyGoodDeed({
    required this.createdAt,
    required this.goodDeedType,
    required this.goodPoint,
    required this.id,
    required this.items,
    required this.transactionID,
    required this.userID,
    required this.userName,
  });

  @override
  List<Object?> get props => [
    createdAt,
    goodDeedType,
    goodPoint,
    id,
    items,
    transactionID,
    userID,
    userName,
  ];
}

class GoodDeedItem extends Equatable {
  final int itemID;
  final String itemImage;
  final String itemName;
  final int postItemID;
  final int quantity;

  const GoodDeedItem({
    required this.itemID,
    required this.itemImage,
    required this.itemName,
    required this.postItemID,
    required this.quantity,           
  });

  @override
  List<Object?> get props => [
    itemID,
    itemImage,
    itemName,
    postItemID,
    quantity,
  ];
}
