import 'package:trao_doi_do_app/data/models/item_warehouse_models.dart';
import 'package:trao_doi_do_app/domain/entities/response/item_warehouse_response.dart';

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
