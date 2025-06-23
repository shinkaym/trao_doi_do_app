import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';

class ClaimItemResponse extends Equatable {
  final ItemWarehouse itemWarehouse;

  const ClaimItemResponse({required this.itemWarehouse});

  @override
  List<Object?> get props => [itemWarehouse];
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

class GetClaimRequestsResponse extends Equatable {
  final List<ClaimRequestItem> claimRequests;

  const GetClaimRequestsResponse({required this.claimRequests});

  @override
  List<Object?> get props => [claimRequests];
}