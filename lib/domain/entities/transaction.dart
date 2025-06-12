import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int? id;
  final int? interestID;
  final List<TransactionItem> items;
  final int? receiverID;
  final String? receiverName;
  final int? senderID;
  final String? senderName;
  final int? status; // 1: Pending, 2: Success, 3: Cancelled
  final String? createdAt;
  final String? updatedAt;

  const Transaction({
    this.id,
    this.interestID,
    this.items = const [],
    this.receiverID,
    this.receiverName,
    this.senderID,
    this.senderName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    interestID,
    items,
    receiverID,
    receiverName,
    senderID,
    senderName,
    status,
    createdAt,
    updatedAt,
  ];
}

class TransactionItem extends Equatable {
  final int? itemID;
  final String? itemName;
  final String? itemImage;
  final int? postItemID;
  final int? quantity;

  const TransactionItem({
    this.itemID,
    this.itemName,
    this.itemImage,
    this.postItemID,
    this.quantity,
  });

  @override
  List<Object?> get props => [itemID, itemName, postItemID, quantity];
}