import 'package:trao_doi_do_app/domain/entities/request/item_warehouse_request.dart';

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
