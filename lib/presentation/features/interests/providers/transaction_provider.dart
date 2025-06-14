import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/models/transaction_model.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/usecases/create_transaction_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_transaction_usecase.dart';

class TransactionState {
  final bool isLoading;
  final Failure? failure;
  final String? successMessage;
  final Transaction? createdTransaction;
  final Transaction? updatedTransaction;

  const TransactionState({
    this.isLoading = false,
    this.failure,
    this.successMessage,
    this.createdTransaction,
    this.updatedTransaction,
  });

  TransactionState copyWith({
    bool? isLoading,
    Failure? failure,
    String? successMessage,
    Transaction? createdTransaction,
    Transaction? updatedTransaction,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      successMessage: successMessage,
      createdTransaction: createdTransaction ?? this.createdTransaction,
      updatedTransaction: updatedTransaction ?? this.updatedTransaction,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final CreateTransactionUseCase _createTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;

  TransactionNotifier(
    this._createTransactionUseCase,
    this._updateTransactionUseCase,
  ) : super(const TransactionState());

  Future<void> createTransaction(CreateTransactionModel transaction) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await _createTransactionUseCase(transaction);

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
    UpdateTransactionModel transaction,
  ) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await _updateTransactionUseCase(transactionID, transaction);

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
}
