import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';
import 'package:trao_doi_do_app/domain/usecases/get_claim_requests_usecase.dart';

class ClaimRequestsListState {
  final bool isLoading;
  final List<ClaimRequestItem> claimRequests;
  final Failure? failure;

  ClaimRequestsListState({
    this.isLoading = false,
    this.claimRequests = const [],
    this.failure,
  });

  ClaimRequestsListState copyWith({
    bool? isLoading,
    List<ClaimRequestItem>? claimRequests,
    Failure? failure,
  }) {
    return ClaimRequestsListState(
      isLoading: isLoading ?? this.isLoading,
      claimRequests: claimRequests ?? this.claimRequests,
      failure: failure,
    );
  }
}

class ClaimRequestsListNotifier extends StateNotifier<ClaimRequestsListState> {
  final GetClaimRequestsUseCase _getClaimRequestsUseCase;

  ClaimRequestsListNotifier(this._getClaimRequestsUseCase)
    : super(ClaimRequestsListState());

  Future<void> loadClaimRequests() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    final result = await _getClaimRequestsUseCase();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (claimRequestsResponse) =>
          state = state.copyWith(
            isLoading: false,
            claimRequests: claimRequestsResponse.claimRequests,
          ),
    );
  }

  void refresh() {
    loadClaimRequests();
  }

  // Helper method to remove an item from the list after deletion
  void removeClaimRequest(int itemID) {
    final updatedClaimRequests =
        state.claimRequests.where((item) => item.itemID != itemID).toList();
    state = state.copyWith(claimRequests: updatedClaimRequests);

    if (updatedClaimRequests.isEmpty) {
      refresh();
    }
  }

  // Helper method to update an item in the list after update
  void updateClaimRequestQuantity(int itemID, int newQuantity) {
    final updatedClaimRequests =
        state.claimRequests.map((item) {
          if (item.itemID == itemID) {
            return ClaimRequestItem(
              categoryName: item.categoryName,
              itemID: item.itemID,
              itemImage: item.itemImage,
              itemName: item.itemName,
              quantity: newQuantity,
            );
          }
          return item;
        }).toList();
    state = state.copyWith(claimRequests: updatedClaimRequests);
  }

  void clearAllClaimRequests() {
    state = state.copyWith(claimRequests: []);
  }
}
