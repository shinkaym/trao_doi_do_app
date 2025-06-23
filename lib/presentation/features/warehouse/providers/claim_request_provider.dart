import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/item_warehouse_request.dart';
import 'package:trao_doi_do_app/domain/entities/response/item_warehouse_response.dart';
import 'package:trao_doi_do_app/domain/usecases/create_claim_request_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_claim_request_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/delete_claim_request_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/delete_all_claim_requests_usecase.dart';

class ClaimRequestState {
  final bool isLoading;
  final bool isSubmitting;
  final Failure? failure;
  final String? successMessage;
  final List<ClaimItemRequest> claimItems;
  final ClaimItemResponse? createdClaimResponse;

  ClaimRequestState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.failure,
    this.successMessage,
    this.claimItems = const [],
    this.createdClaimResponse,
  });

  ClaimRequestState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    Failure? failure,
    String? successMessage,
    List<ClaimItemRequest>? claimItems,
    ClaimItemResponse? createdClaimResponse,
  }) {
    return ClaimRequestState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure,
      successMessage: successMessage,
      claimItems: claimItems ?? this.claimItems,
      createdClaimResponse: createdClaimResponse ?? this.createdClaimResponse,
    );
  }
}

class ClaimRequestNotifier extends StateNotifier<ClaimRequestState> {
  final CreateClaimRequestUseCase _createClaimRequestUseCase;
  final UpdateClaimRequestUseCase _updateClaimRequestUseCase;
  final DeleteClaimRequestUseCase _deleteClaimRequestUseCase;
  final DeleteAllClaimRequestsUseCase _deleteAllClaimRequestsUseCase;

  ClaimRequestNotifier(
    this._createClaimRequestUseCase,
    this._updateClaimRequestUseCase,
    this._deleteClaimRequestUseCase,
    this._deleteAllClaimRequestsUseCase,
  ) : super(ClaimRequestState());

  void addClaimItem(int itemID, int quantity) {
    final newClaimItem = ClaimItemRequest(itemID: itemID, quantity: quantity);
    final updatedClaimItems = [...state.claimItems, newClaimItem];
    state = state.copyWith(claimItems: updatedClaimItems);
  }

  void removeClaimItem(int index) {
    final updatedClaimItems = [...state.claimItems];
    updatedClaimItems.removeAt(index);
    state = state.copyWith(claimItems: updatedClaimItems);
  }

  void updateClaimItemQuantity(int index, int newQuantity) {
    final updatedClaimItems = [...state.claimItems];
    updatedClaimItems[index] = ClaimItemRequest(
      itemID: updatedClaimItems[index].itemID,
      quantity: newQuantity,
    );
    state = state.copyWith(claimItems: updatedClaimItems);
  }

  void clearClaimItems() {
    state = state.copyWith(claimItems: []);
  }

  Future<void> createClaimRequest() async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, failure: null);

    final result = await _createClaimRequestUseCase(state.claimItems);

    result.fold(
      (failure) =>
          state = state.copyWith(isSubmitting: false, failure: failure),
      (claimResponse) =>
          state = state.copyWith(
            isSubmitting: false,
            createdClaimResponse: claimResponse,
            successMessage: 'Tạo yêu cầu claim thành công!',
            claimItems: [], // Clear items after successful creation
          ),
    );
  }

  Future<void> updateClaimRequest(int itemID, int newQuantity) async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, failure: null);

    final result = await _updateClaimRequestUseCase(itemID, newQuantity);

    result.fold(
      (failure) =>
          state = state.copyWith(isSubmitting: false, failure: failure),
      (message) =>
          state = state.copyWith(
            isSubmitting: false,
            successMessage: 'Cập nhật yêu cầu claim thành công!',
          ),
    );
  }

  Future<void> deleteClaimRequest(int itemID) async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, failure: null);

    final result = await _deleteClaimRequestUseCase(itemID);

    result.fold(
      (failure) =>
          state = state.copyWith(isSubmitting: false, failure: failure),
      (message) =>
          state = state.copyWith(
            isSubmitting: false,
            successMessage: 'Xóa yêu cầu claim thành công!',
          ),
    );
  }

  Future<void> deleteAllClaimRequests() async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, failure: null);

    final result = await _deleteAllClaimRequestsUseCase();

    result.fold(
      (failure) =>
          state = state.copyWith(isSubmitting: false, failure: failure),
      (message) =>
          state = state.copyWith(
            isSubmitting: false,
            successMessage: 'Xóa tất cả yêu cầu claim thành công!',
          ),
    );
  }

  void clearMessages() {
    state = state.copyWith(failure: null, successMessage: null);
  }
}
