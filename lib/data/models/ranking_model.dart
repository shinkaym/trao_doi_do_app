import 'package:trao_doi_do_app/domain/entities/ranking.dart';

class UserRankingResponseModel {
  final int totalPage;
  final List<UserRankModel> userRanks;
  final UserRankModel yourInfo;
  final int yourRank;

  const UserRankingResponseModel({
    required this.totalPage,
    required this.userRanks,
    required this.yourInfo,
    required this.yourRank,
  });

  factory UserRankingResponseModel.fromJson(Map<String, dynamic> json) {
    return UserRankingResponseModel(
      totalPage: json['totalPage'] as int,
      userRanks:
          (json['userRanks'] as List<dynamic>)
              .map(
                (user) => UserRankModel.fromJson(user as Map<String, dynamic>),
              )
              .toList(),
      yourInfo: UserRankModel.fromJson(
        json['yourInfo'] as Map<String, dynamic>,
      ),
      yourRank: json['yourRank'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPage': totalPage,
      'userRanks': userRanks.map((user) => user.toJson()).toList(),
      'yourInfo': yourInfo.toJson(),
      'yourRank': yourRank,
    };
  }

  UserRankingResponse toEntity() {
    return UserRankingResponse(
      totalPage: totalPage,
      userRanks: userRanks.map((user) => user.toEntity()).toList(),
      yourInfo: yourInfo.toEntity(),
      yourRank: yourRank,
    );
  }
}

class UserRankModel {
  final List<GoodDeedModel> goodDeeds;
  final int goodPoint;
  final String major;
  final String userAvatar;
  final int userID;
  final String userName;

  const UserRankModel({
    required this.goodDeeds,
    required this.goodPoint,
    required this.major,
    required this.userAvatar,
    required this.userID,
    required this.userName,
  });

  factory UserRankModel.fromJson(Map<String, dynamic> json) {
    return UserRankModel(
      goodDeeds:
          (json['goodDeeds'] as List<dynamic>)
              .map(
                (deed) => GoodDeedModel.fromJson(deed as Map<String, dynamic>),
              )
              .toList(),
      goodPoint: json['goodPoint'] as int,
      major: json['major'] as String? ?? '',
      userAvatar: json['userAvatar'] as String? ?? '',
      userID: json['userID'] as int,
      userName: json['userName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goodDeeds': goodDeeds.map((deed) => deed.toJson()).toList(),
      'goodPoint': goodPoint,
      'major': major,
      'userAvatar': userAvatar,
      'userID': userID,
      'userName': userName,
    };
  }

  UserRank toEntity() {
    return UserRank(
      goodDeeds: goodDeeds.map((deed) => deed.toEntity()).toList(),
      goodPoint: goodPoint,
      major: major,
      userAvatar: userAvatar,
      userID: userID,
      userName: userName,
    );
  }
}

class GoodDeedModel {
  final int goodDeedCount;
  final int goodDeedType;

  const GoodDeedModel({
    required this.goodDeedCount,
    required this.goodDeedType,
  });

  factory GoodDeedModel.fromJson(Map<String, dynamic> json) {
    return GoodDeedModel(
      goodDeedCount: json['goodDeedCount'] as int,
      goodDeedType: json['goodDeedType'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'goodDeedCount': goodDeedCount, 'goodDeedType': goodDeedType};
  }

  GoodDeed toEntity() {
    return GoodDeed(goodDeedCount: goodDeedCount, goodDeedType: goodDeedType);
  }
}

class MyGoodDeedsResponseModel {
  final List<MyGoodDeedModel> goodDeeds;

  const MyGoodDeedsResponseModel({required this.goodDeeds});

  factory MyGoodDeedsResponseModel.fromJson(Map<String, dynamic> json) {
    return MyGoodDeedsResponseModel(
      goodDeeds:
          (json['goodDeeds'] as List<dynamic>)
              .map(
                (deed) =>
                    MyGoodDeedModel.fromJson(deed as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'goodDeeds': goodDeeds.map((deed) => deed.toJson()).toList()};
  }

  MyGoodDeedsResponse toEntity() {
    return MyGoodDeedsResponse(
      goodDeeds: goodDeeds.map((deed) => deed.toEntity()).toList(),
    );
  }
}

class MyGoodDeedModel {
  final String createdAt;
  final int goodDeedType;
  final int goodPoint;
  final int id;
  final List<GoodDeedItemModel> items;
  final int transactionID;
  final int userID;
  final String userName;

  const MyGoodDeedModel({
    required this.createdAt,
    required this.goodDeedType,
    required this.goodPoint,
    required this.id,
    required this.items,
    required this.transactionID,
    required this.userID,
    required this.userName,
  });

  factory MyGoodDeedModel.fromJson(Map<String, dynamic> json) {
    return MyGoodDeedModel(
      createdAt: json['createdAt'] as String? ?? '',
      goodDeedType: json['goodDeedType'] as int,
      goodPoint: json['goodPoint'] as int,
      id: json['id'] as int,
      items:
          (json['items'] as List<dynamic>)
              .map(
                (item) =>
                    GoodDeedItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      transactionID: json['transactionID'] as int,
      userID: json['userID'] as int,
      userName: json['userName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'goodDeedType': goodDeedType,
      'goodPoint': goodPoint,
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'transactionID': transactionID,
      'userID': userID,
      'userName': userName,
    };
  }

  MyGoodDeed toEntity() {
    return MyGoodDeed(
      createdAt: createdAt,
      goodDeedType: goodDeedType,
      goodPoint: goodPoint,
      id: id,
      items: items.map((item) => item.toEntity()).toList(),
      transactionID: transactionID,
      userID: userID,
      userName: userName,
    );
  }
}

class GoodDeedItemModel {
  final int itemID;
  final String itemImage;
  final String itemName;
  final int postItemID;
  final int quantity;

  const GoodDeedItemModel({
    required this.itemID,
    required this.itemImage,
    required this.itemName,
    required this.postItemID,
    required this.quantity,
  });

  factory GoodDeedItemModel.fromJson(Map<String, dynamic> json) {
    return GoodDeedItemModel(
      itemID: json['itemID'] as int,
      itemImage: json['itemImage'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      postItemID: json['postItemID'] as int,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'itemImage': itemImage,
      'itemName': itemName,
      'postItemID': postItemID,
      'quantity': quantity,
    };
  }

  GoodDeedItem toEntity() {
    return GoodDeedItem(
      itemID: itemID,
      itemImage: itemImage,
      itemName: itemName,
      postItemID: postItemID,
      quantity: quantity,
    );
  }
}
