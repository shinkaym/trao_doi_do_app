import 'package:equatable/equatable.dart';

class ClaimItemRequest extends Equatable {
  final int itemID;
  final int quantity;

  const ClaimItemRequest({
    required this.itemID,
    required this.quantity,
  });

  @override
  List<Object?> get props => [itemID, quantity];
}

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

class ClaimItemResponse extends Equatable {
  final ItemWarehouse itemWarehouse;

  const ClaimItemResponse({required this.itemWarehouse});

  @override
  List<Object?> get props => [itemWarehouse];
}

class OldStockItem extends Equatable {
  final String categoryName;
  final int claimItemRequests;
  final String description;
  final int itemId;
  final String itemImage;
  final String itemName;
  final int quantity;

  const OldStockItem({
    required this.categoryName,
    required this.claimItemRequests,
    required this.description,
    required this.itemId,
    required this.itemImage,
    required this.itemName,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
        categoryName,
        claimItemRequests,
        description,
        itemId,
        itemImage,
        itemName,
        quantity,
      ];
}

class OldStockResponse extends Equatable {
  final List<OldStockItem> itemOldStocks;
  final int totalPage;

  const OldStockResponse({
    required this.itemOldStocks,
    required this.totalPage,
  });

  @override
  List<Object?> get props => [itemOldStocks, totalPage];
}