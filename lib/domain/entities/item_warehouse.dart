import 'package:equatable/equatable.dart';

class ItemWarehouse extends Equatable {
  final int id;
  final int itemID;
  final int warehouseID;
  final String categoryName;
  final String code;
  final String description;
  final String itemName;
  final int status;

  const ItemWarehouse({
    required this.id,
    required this.itemID,
    required this.warehouseID,
    required this.categoryName,
    required this.code,
    required this.description,
    required this.itemName,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    itemID,
    warehouseID,
    categoryName,
    code,
    description,
    itemName,
    status,
  ];
}

class OldStockItem extends Equatable {
  final String categoryName;
  final int claimItemRequests;
  final String description;
  final int itemID;
  final String itemImage;
  final String itemName;
  final int quantity;

  const OldStockItem({
    required this.categoryName,
    required this.claimItemRequests,
    required this.description,
    required this.itemID,
    required this.itemImage,
    required this.itemName,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
    categoryName,
    claimItemRequests,
    description,
    itemID,
    itemImage,
    itemName,
    quantity,
  ];
}

class ClaimRequestItem extends Equatable {
  final String categoryName;
  final int itemID;
  final String itemImage;
  final String itemName;
  final int quantity;

  const ClaimRequestItem({
    required this.categoryName,
    required this.itemID,
    required this.itemImage,
    required this.itemName,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
        categoryName,
        itemID,
        itemImage,
        itemName,
        quantity,
      ];
}