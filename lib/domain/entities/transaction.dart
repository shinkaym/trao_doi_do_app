import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int id;
  final int interestID;
  final List<TransactionItem> items;
  final int receiverID;
  final String receiverName;
  final int senderID;
  final String senderName;
  final int status; // 1: Pending, 2: Success, 3: Cancelled
  final String createdAt;
  final String? updatedAt;

  const Transaction({
    required this.id,
    required this.interestID,
    this.items = const [],
    required this.receiverID,
    required this.receiverName,
    required this.senderID,
    required this.senderName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
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
  final int itemID;
  final String itemName;
  final String itemImage;
  final int postItemID;
  final int quantity;

  const TransactionItem({
    required this.itemID,
    required this.itemName,
    required this.itemImage,
    required this.postItemID,
    required this.quantity,
  });

  @override
  List<Object?> get props => [itemID, itemName, postItemID, quantity];
}