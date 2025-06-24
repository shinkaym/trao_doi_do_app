import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';

class ItemWarehouseModel {
  final int id;
  final int itemID;
  final int warehouseID;
  final String categoryName;
  final String code;
  final String description;
  final String itemName;
  final int status;

  const ItemWarehouseModel({
    required this.id,
    required this.itemID,
    required this.warehouseID,
    required this.categoryName,
    required this.code,
    required this.description,
    required this.itemName,
    required this.status,
  });

  factory ItemWarehouseModel.fromJson(Map<String, dynamic> json) {
    return ItemWarehouseModel(
      id: json['id'] as int,
      itemID: json['itemID'] as int,
      warehouseID: json['warehouseID'] as int,
      categoryName: json['categoryName'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      itemName: json['itemName'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemID': itemID,
      'warehouseID': warehouseID,
      'categoryName': categoryName,
      'code': code,
      'description': description,
      'itemName': itemName,
      'status': status,
    };
  }

  ItemWarehouse toEntity() {
    return ItemWarehouse(
      id: id,
      itemID: itemID,
      warehouseID: warehouseID,
      categoryName: categoryName,
      code: code,
      description: description,
      itemName: itemName,
      status: status,
    );
  }

  factory ItemWarehouseModel.fromEntity(ItemWarehouse entity) {
    return ItemWarehouseModel(
      id: entity.id,
      itemID: entity.itemID,
      warehouseID: entity.warehouseID,
      categoryName: entity.categoryName,
      code: entity.code,
      description: entity.description,
      itemName: entity.itemName,
      status: entity.status,
    );
  }
}

class OldStockItemModel {
  final String categoryName;
  final int claimItemRequests;
  final String description;
  final int itemID;
  final String itemImage;
  final String itemName;
  final int quantity;

  const OldStockItemModel({
    required this.categoryName,
    required this.claimItemRequests,
    required this.description,
    required this.itemID,
    required this.itemImage,
    required this.itemName,
    required this.quantity,
  });

  factory OldStockItemModel.fromJson(Map<String, dynamic> json) {
    return OldStockItemModel(
      categoryName: json['categoryName'] as String,
      claimItemRequests: json['claimItemRequests'] as int,
      description: json['description'] as String,
      itemID: json['itemID'] as int,
      itemImage: json['itemImage'] as String,
      itemName: json['itemName'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'claimItemRequests': claimItemRequests,
      'description': description,
      'itemID': itemID,
      'itemImage': itemImage,
      'itemName': itemName,
      'quantity': quantity,
    };
  }

  OldStockItem toEntity() {
    return OldStockItem(
      categoryName: categoryName,
      claimItemRequests: claimItemRequests,
      description: description,
      itemID: itemID,
      itemImage: itemImage,
      itemName: itemName,
      quantity: quantity,
    );
  }

  factory OldStockItemModel.fromEntity(OldStockItem entity) {
    return OldStockItemModel(
      categoryName: entity.categoryName,
      claimItemRequests: entity.claimItemRequests,
      description: entity.description,
      itemID: entity.itemID,
      itemImage: entity.itemImage,
      itemName: entity.itemName,
      quantity: entity.quantity,
    );
  }
}

class ClaimRequestItemModel {
  final String categoryName;
  final int itemID;
  final String itemImage;
  final String itemName;
  final int quantity;

  const ClaimRequestItemModel({
    required this.categoryName,
    required this.itemID,
    required this.itemImage,
    required this.itemName,
    required this.quantity,
  });

  factory ClaimRequestItemModel.fromJson(Map<String, dynamic> json) {
    return ClaimRequestItemModel(
      categoryName: json['categoryName'] as String,
      itemID: json['itemID'] as int,
      itemImage: json['itemImage'] as String,
      itemName: json['itemName'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'itemID': itemID,
      'itemImage': itemImage,
      'itemName': itemName,
      'quantity': quantity,
    };
  }

  ClaimRequestItem toEntity() {
    return ClaimRequestItem(
      categoryName: categoryName,
      itemID: itemID,
      itemImage: itemImage,
      itemName: itemName,
      quantity: quantity,
    );
  }

  factory ClaimRequestItemModel.fromEntity(ClaimRequestItem entity) {
    return ClaimRequestItemModel(
      categoryName: entity.categoryName,
      itemID: entity.itemID,
      itemImage: entity.itemImage,
      itemName: entity.itemName,
      quantity: entity.quantity,
    );
  }
}
