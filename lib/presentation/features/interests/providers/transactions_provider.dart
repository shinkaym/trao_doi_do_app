import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/entities/params/transactions_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_transactions_usecase.dart';

class TransactionsListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Transaction> transactions;
  final int currentPage;
  final int totalPage;
  final TransactionsQuery query;
  final Failure? failure;
  final bool hasMoreData;
  final bool isLoadingPage;

  TransactionsListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.transactions = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const TransactionsQuery(),
    this.failure,
    this.hasMoreData = true,
    this.isLoadingPage = false,
  });

  TransactionsListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Transaction>? transactions,
    int? currentPage,
    int? totalPage,
    TransactionsQuery? query,
    Failure? failure,
    bool? hasMoreData,
    bool? isLoadingPage,
  }) {
    return TransactionsListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage != null ? totalPage : this.totalPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
    );
  }
}

class TransactionsListNotifier extends StateNotifier<TransactionsListState> {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionsListNotifier(this._getTransactionsUseCase)
    : super(TransactionsListState());

  // Load transactions with various options
  Future<void> loadTransactions({
    TransactionsQuery? newQuery,
    bool refresh = false,
    bool isLoadMore = false,
    bool isGoToPage = false,
  }) async {
    if (state.isLoading || state.isLoadingMore || state.isLoadingPage) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.transactions.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
      );
    } else if (isLoadMore) {
      if (!state.hasMoreData || state.currentPage >= state.totalPage) return;

      state = state.copyWith(
        isLoadingMore: true,
        failure: null,
        query: query.copyWith(page: state.currentPage + 1),
      );
    } else if (isGoToPage) {
      state = state.copyWith(isLoadingPage: true, failure: null, query: query);
    }

    final result = await _getTransactionsUseCase(query);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            isLoadingPage: false,
            failure: failure,
          ),
      (transactionsResult) {
        List<Transaction> newTransactions;

        if (isFirstLoad) {
          newTransactions = transactionsResult.transactions;
        } else if (isLoadMore) {
          newTransactions = [
            ...state.transactions,
            ...transactionsResult.transactions,
          ];
        } else if (isGoToPage) {
          newTransactions = transactionsResult.transactions;
        } else {
          newTransactions = state.transactions;
        }

        final actualTotalPage = transactionsResult.totalPage;
        final actualCurrentPage = actualTotalPage > 0 ? state.query.page : 1;
        final actualHasMoreData =
            actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          isLoadingPage: false,
          transactions: newTransactions,
          currentPage: actualCurrentPage,
          totalPage: actualTotalPage,
          hasMoreData: actualHasMoreData,
        );
      },
    );
  }

  // Navigation methods
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPage || page == state.currentPage) return;

    final newQuery = state.query.copyWith(page: page);
    await loadTransactions(newQuery: newQuery, isGoToPage: true);
  }

  Future<void> goToPreviousPage() async {
    if (state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    }
  }

  Future<void> goToNextPage() async {
    if (state.currentPage < state.totalPage) {
      await goToPage(state.currentPage + 1);
    }
  }

  Future<void> goToFirstPage() async {
    await goToPage(1);
  }

  Future<void> goToLastPage() async {
    await goToPage(state.totalPage);
  }

  // Filter methods
  void filterByStatus(int? status) {
    final newQuery = state.query.copyWith(status: status);
    loadTransactions(newQuery: newQuery, refresh: true);
  }

  void search(String? searchBy, String? searchValue) {
    final newQuery = state.query.copyWith(
      searchBy: searchBy,
      searchValue: searchValue,
    );
    loadTransactions(newQuery: newQuery, refresh: true);
  }

  void sortTransactions(String? sort, String? order) {
    final newQuery = state.query.copyWith(sort: sort, order: order);
    loadTransactions(newQuery: newQuery, refresh: true);
  }

  void applyFilter({
    String? searchBy,
    String? searchValue,
    int? status,
    String? sort,
    String? order,
  }) {
    final newQuery = state.query.copyWith(
      searchBy: searchBy,
      searchValue: searchValue,
      status: status,
      sort: sort,
      order: order,
      page: 1,
    );
    loadTransactions(newQuery: newQuery, refresh: true);
  }

  // Load more for infinite scroll
  void loadMore() {
    loadTransactions(isLoadMore: true);
  }

  void refresh() {
    loadTransactions(refresh: true);
  }
}

final transactionsListProvider =
    StateNotifierProvider<TransactionsListNotifier, TransactionsListState>((
      ref,
    ) {
      final getTransactionsUseCase = ref.watch(getTransactionsUseCaseProvider);
      return TransactionsListNotifier(getTransactionsUseCase);
    });
