import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';

class ClaimItemRequestModel {
  final int itemID;
  final int quantity;

  const ClaimItemRequestModel({required this.itemID, required this.quantity});

  factory ClaimItemRequestModel.fromEntity(ClaimItemRequest entity) {
    return ClaimItemRequestModel(
      itemID: entity.itemID,
      quantity: entity.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {'itemID': itemID, 'quantity': quantity};
  }

  ClaimItemRequest toEntity() {
    return ClaimItemRequest(itemID: itemID, quantity: quantity);
  }
}

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

class ClaimItemResponseModel {
  final ItemWarehouseModel itemWarehouse;

  const ClaimItemResponseModel({required this.itemWarehouse});

  factory ClaimItemResponseModel.fromJson(Map<String, dynamic> json) {
    return ClaimItemResponseModel(
      itemWarehouse: ItemWarehouseModel.fromJson(
        json['itemWarehouse'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'itemWarehouse': itemWarehouse.toJson()};
  }

  ClaimItemResponse toEntity() {
    return ClaimItemResponse(itemWarehouse: itemWarehouse.toEntity());
  }

  factory ClaimItemResponseModel.fromEntity(ClaimItemResponse entity) {
    return ClaimItemResponseModel(
      itemWarehouse: ItemWarehouseModel.fromEntity(entity.itemWarehouse),
    );
  }
}

class OldStockItemModel {
  final String categoryName;
  final int claimItemRequests;
  final String description;
  final int itemId;
  final String itemImage;
  final String itemName;
  final int quantity;

  const OldStockItemModel({
    required this.categoryName,
    required this.claimItemRequests,
    required this.description,
    required this.itemId,
    required this.itemImage,
    required this.itemName,
    required this.quantity,
  });

  factory OldStockItemModel.fromJson(Map<String, dynamic> json) {
    return OldStockItemModel(
      categoryName: json['category_name'] as String,
      claimItemRequests: json['claim_item_requests'] as int,
      description: json['description'] as String,
      itemId: json['item_id'] as int,
      itemImage: json['item_image'] as String,
      itemName: json['item_name'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'claim_item_requests': claimItemRequests,
      'description': description,
      'item_id': itemId,
      'item_image': itemImage,
      'item_name': itemName,
      'quantity': quantity,
    };
  }

  OldStockItem toEntity() {
    return OldStockItem(
      categoryName: categoryName,
      claimItemRequests: claimItemRequests,
      description: description,
      itemId: itemId,
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
      itemId: entity.itemId,
      itemImage: entity.itemImage,
      itemName: entity.itemName,
      quantity: entity.quantity,
    );
  }
}

class OldStockResponseModel {
  final List<OldStockItemModel> itemOldStocks;
  final int totalPage;

  const OldStockResponseModel({
    required this.itemOldStocks,
    required this.totalPage,
  });

  factory OldStockResponseModel.fromJson(Map<String, dynamic> json) {
    return OldStockResponseModel(
      itemOldStocks:
          (json['itemOldStocks'] as List<dynamic>)
              .map(
                (item) =>
                    OldStockItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      totalPage: json['totalPage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemOldStocks': itemOldStocks.map((item) => item.toJson()).toList(),
      'totalPage': totalPage,
    };
  }

  OldStockResponse toEntity() {
    return OldStockResponse(
      itemOldStocks: itemOldStocks.map((item) => item.toEntity()).toList(),
      totalPage: totalPage,
    );
  }

  factory OldStockResponseModel.fromEntity(OldStockResponse entity) {
    return OldStockResponseModel(
      itemOldStocks:
          entity.itemOldStocks
              .map((item) => OldStockItemModel.fromEntity(item))
              .toList(),
      totalPage: entity.totalPage,
    );
  }
}
