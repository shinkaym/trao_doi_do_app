import 'package:trao_doi_do_app/domain/entities/transaction.dart';

class TransactionModel {
  final int id;
  final int interestID;
  final List<TransactionItemModel> items;
  final int receiverID;
  final String receiverName;
  final int senderID;
  final String senderName;
  final int status;
  final String createdAt;
  final String? updatedAt;

  const TransactionModel({
    required this.id,
    required this.interestID,
    this.items = const [],
    required this.receiverID,
    required this.receiverName,
    required this.senderID,
    required this.senderName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      interestID: transaction.interestID,
      items:
          transaction.items
              .map((item) => TransactionItemModel.fromEntity(item))
              .toList(),
      receiverID: transaction.receiverID,
      receiverName: transaction.receiverName,
      senderID: transaction.senderID,
      senderName: transaction.senderName,
      status: transaction.status,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> transactionData;

    if (json.containsKey('transaction')) {
      transactionData = json['transaction'] as Map<String, dynamic>;
    } else {
      transactionData = json;
    }

    return TransactionModel(
      id: transactionData['id'] ?? 0,
      interestID: transactionData['interestID'] ?? 0,
      items:
          transactionData['items'] != null
              ? (transactionData['items'] as List)
                  .map(
                    (item) => TransactionItemModel.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : [],
      receiverID: transactionData['receiverID'] ?? 0,
      receiverName: transactionData['receiverName'] ?? '',
      senderID: transactionData['senderID'] ?? 0,
      senderName: transactionData['senderName'] ?? '',
      status: transactionData['status'] ?? 1,
      createdAt:
          transactionData['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: transactionData['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interestID': interestID,
      'items': items.map((item) => item.toJson()).toList(),
      'receiverID': receiverID,
      'receiverName': receiverName,
      'senderID': senderID,
      'senderName': senderName,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      interestID: interestID,
      items: items.map((item) => item.toEntity()).toList(),
      receiverID: receiverID,
      receiverName: receiverName,
      senderID: senderID,
      senderName: senderName,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class TransactionItemModel {
  final int? itemID;
  final String itemName;
  final String itemImage;
  final int postItemID;
  final int quantity;

  const TransactionItemModel({
    this.itemID,
    this.itemName = '',
    this.itemImage = '',
    required this.postItemID,
    required this.quantity,
  });

  factory TransactionItemModel.fromEntity(TransactionItem item) {
    return TransactionItemModel(
      itemID: item.itemID,
      itemName: item.itemName,
      itemImage: item.itemImage,
      postItemID: item.postItemID,
      quantity: item.quantity,
    );
  }

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      itemID: json['itemID'] ?? 0,
      itemName: json['itemName'] ?? '',
      itemImage: json['itemImage'] ?? '',
      postItemID: json['postItemID'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'itemName': itemName,
      'itemImage': itemImage,
      'postItemID': postItemID,
      'quantity': quantity,
    };
  }

  TransactionItem toEntity() {
    return TransactionItem(
      itemID: itemID,
      itemName: itemName,
      itemImage: itemImage,
      postItemID: postItemID,
      quantity: quantity,
    );
  }
}
