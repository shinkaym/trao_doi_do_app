import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/transaction_request.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/usecases/create_transaction_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_transaction_by_interest_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_transaction_usecase.dart';

class TransactionState {
  final bool isLoading;
  final bool isLoadingByInterest;
  final Failure? failure;
  final String? successMessage;
  final Transaction? createdTransaction;
  final Transaction? updatedTransaction;
  final Transaction? transactionByInterest;

  const TransactionState({
    this.isLoading = false,
    this.isLoadingByInterest = false,
    this.failure,
    this.successMessage,
    this.createdTransaction,
    this.updatedTransaction,
    this.transactionByInterest,
  });

  TransactionState copyWith({
    bool? isLoading,
    bool? isLoadingByInterest,
    Failure? failure,
    String? successMessage,
    Transaction? createdTransaction,
    Transaction? updatedTransaction,
    Transaction? transactionByInterest,
    bool clearTransactionByInterest = false,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingByInterest: isLoadingByInterest ?? this.isLoadingByInterest,
      failure: failure,
      successMessage: successMessage,
      createdTransaction: createdTransaction ?? this.createdTransaction,
      updatedTransaction: updatedTransaction ?? this.updatedTransaction,
      transactionByInterest:
          clearTransactionByInterest
              ? null
              : (transactionByInterest ?? this.transactionByInterest),
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final CreateTransactionUseCase _createTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final GetTransactionByInterestUseCase _getTransactionByInterestUseCase;

  TransactionNotifier(
    this._createTransactionUseCase,
    this._updateTransactionUseCase,
    this._getTransactionByInterestUseCase,
  ) : super(const TransactionState());

  Future<void> getTransactionByInterest(int interestID) async {
    state = state.copyWith(isLoadingByInterest: true, failure: null);

    final result = await _getTransactionByInterestUseCase(interestID);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoadingByInterest: false,
            failure: failure,
            clearTransactionByInterest: true, // Clear dữ liệu cũ khi có lỗi
          ),
      (transaction) =>
          state = state.copyWith(
            isLoadingByInterest: false,
            transactionByInterest: transaction,
          ),
    );
  }

  Future<void> createTransaction(CreateTransactionRequest request) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await _createTransactionUseCase(request);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (createdTransaction) =>
          state = state.copyWith(
            isLoading: false,
            createdTransaction: createdTransaction,
            successMessage: 'Tạo giao dịch thành công!',
          ),
    );
  }

  Future<void> updateTransaction(
    int transactionID,
    UpdateTransactionRequest request,
  ) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await _updateTransactionUseCase(transactionID, request);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (updatedTransaction) =>
          state = state.copyWith(
            isLoading: false,
            updatedTransaction: updatedTransaction,
            successMessage: 'Cập nhật giao dịch thành công!',
          ),
    );
  }

  void clearState() {
    state = const TransactionState();
  }

  void clearTransactionByInterest() {
    state = state.copyWith(clearTransactionByInterest: true);
  }
}
