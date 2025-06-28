import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/usecases/get_transaction_by_interest_usecase.dart';

// State cho transaction của từng interest
class TransactionByInterestState {
  final bool isLoading;
  final Failure? failure;
  final Transaction? transaction;

  const TransactionByInterestState({
    this.isLoading = false,
    this.failure,
    this.transaction,
  });

  TransactionByInterestState copyWith({
    bool? isLoading,
    Failure? failure,
    Transaction? transaction,
    bool clearTransaction = false,
  }) {
    return TransactionByInterestState(
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      transaction: clearTransaction ? null : (transaction ?? this.transaction),
    );
  }
}

// Notifier cho transaction của từng interest
class TransactionByInterestNotifier
    extends StateNotifier<TransactionByInterestState> {
  final GetTransactionByInterestUseCase _getTransactionByInterestUseCase;
  final int interestId;

  TransactionByInterestNotifier(
    this._getTransactionByInterestUseCase,
    this.interestId,
  ) : super(const TransactionByInterestState());

  Future<void> loadTransaction() async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await _getTransactionByInterestUseCase(interestId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            failure: failure,
            clearTransaction: true,
          ),
      (transaction) =>
          state = state.copyWith(isLoading: false, transaction: transaction),
    );
  }

  void clearState() {
    state = const TransactionByInterestState();
  }
}
