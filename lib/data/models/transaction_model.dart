import 'package:trao_doi_do_app/domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    super.id,
    super.interestID,
    super.items,
    super.receiverID,
    super.receiverName,
    super.senderID,
    super.senderName,
    super.status,
    super.createdAt,
    super.updatedAt,
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
    return TransactionModel(
      id: json['id'],
      interestID: json['interestID'],
      items:
          json['items'] != null
              ? (json['items'] as List)
                  .map(
                    (item) => TransactionItemModel.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : [],
      receiverID: json['receiverID'],
      receiverName: json['receiverName'] ?? '',
      senderID: json['senderID'],
      senderName: json['senderName'] ?? '',
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interestID': interestID,
      'items':
          items.map((item) => (item as TransactionItemModel).toJson()).toList(),
      'receiverID': receiverID,
      'receiverName': receiverName,
      'senderID': senderID,
      'senderName': senderName,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class TransactionItemModel extends TransactionItem {
  const TransactionItemModel({
    super.itemID,
    super.itemName,
    super.itemImage,
    super.postItemID,
    super.quantity,
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
      itemID: json['itemID'],
      itemName: json['itemName'] ?? '',
      itemImage: json['itemImage'] ?? '',
      postItemID: json['postItemID'],
      quantity: json['quantity'],
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
}

class CreateTransactionModel {
  final int interestID;
  final List<CreateTransactionItemModel> items;

  const CreateTransactionModel({required this.interestID, required this.items});

  Map<String, dynamic> toJson() {
    return {
      'interestID': interestID,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory CreateTransactionModel.fromJson(Map<String, dynamic> json) {
    return CreateTransactionModel(
      interestID: json['interestID'],
      items:
          (json['items'] as List)
              .map(
                (item) => CreateTransactionItemModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}

class CreateTransactionItemModel {
  final int postItemID;
  final int quantity;

  const CreateTransactionItemModel({
    required this.postItemID,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {'postItemID': postItemID, 'quantity': quantity};
  }

  factory CreateTransactionItemModel.fromJson(Map<String, dynamic> json) {
    return CreateTransactionItemModel(
      postItemID: json['postItemID'],
      quantity: json['quantity'],
    );
  }
}

class UpdateTransactionModel {
  final List<UpdateTransactionItemModel> items;
  final int status;

  const UpdateTransactionModel({required this.items, required this.status});

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
    };
  }

  factory UpdateTransactionModel.fromJson(Map<String, dynamic> json) {
    return UpdateTransactionModel(
      items:
          (json['items'] as List)
              .map(
                (item) => UpdateTransactionItemModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      status: json['status'],
    );
  }
}

class UpdateTransactionItemModel {
  final int postItemID;
  final int quantity;
  final int transactionID;

  const UpdateTransactionItemModel({
    required this.postItemID,
    required this.quantity,
    required this.transactionID,
  });

  Map<String, dynamic> toJson() {
    return {
      'postItemID': postItemID,
      'quantity': quantity,
      'transactionID': transactionID,
    };
  }

  factory UpdateTransactionItemModel.fromJson(Map<String, dynamic> json) {
    return UpdateTransactionItemModel(
      postItemID: json['postItemID'],
      quantity: json['quantity'],
      transactionID: json['transactionID'],
    );
  }
}
