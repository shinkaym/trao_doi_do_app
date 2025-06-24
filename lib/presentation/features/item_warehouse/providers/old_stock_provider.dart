import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';
import 'package:trao_doi_do_app/domain/usecases/get_old_stock_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/params/old_stock_query.dart';

class OldStockState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isLoadingPage;
  final List<OldStockItem> items;
  final int currentPage;
  final int totalPage;
  final OldStockQuery query;
  final Failure? failure;
  final bool hasMoreData;

  OldStockState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isLoadingPage = false,
    this.items = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const OldStockQuery(),
    this.failure,
    this.hasMoreData = true,
  });

  OldStockState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isLoadingPage,
    List<OldStockItem>? items,
    int? currentPage,
    int? totalPage,
    OldStockQuery? query,
    Failure? failure,
    bool? hasMoreData,
  }) {
    return OldStockState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class OldStockNotifier extends StateNotifier<OldStockState> {
  final GetOldStockUseCase _getOldStockUseCase;

  OldStockNotifier(this._getOldStockUseCase) : super(OldStockState());

  Future<void> loadOldStock({
    OldStockQuery? newQuery,
    bool refresh = false,
    bool isLoadMore = false,
    bool isGoToPage = false,
  }) async {
    if (state.isLoading || state.isLoadingMore || state.isLoadingPage) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.items.isEmpty;

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

    final result = await _getOldStockUseCase(state.query);
    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            isLoadingPage: false,
            failure: failure,
          ),
      (oldStockResponse) {
        List<OldStockItem> newItems;

        if (isFirstLoad) {
          newItems = oldStockResponse.itemOldStocks;
        } else if (isLoadMore) {
          newItems = [...state.items, ...oldStockResponse.itemOldStocks];
        } else if (isGoToPage) {
          newItems = oldStockResponse.itemOldStocks;
        } else {
          newItems = state.items;
        }

        final actualTotalPage = oldStockResponse.totalPage;
        final actualCurrentPage = actualTotalPage > 0 ? state.query.page : 1;
        final actualHasMoreData =
            actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          isLoadingPage: false,
          items: newItems,
          currentPage: actualCurrentPage,
          totalPage: actualTotalPage,
          hasMoreData: actualHasMoreData,
        );
      },
    );
  }

  // Pagination methods
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPage || page == state.currentPage) return;

    final newQuery = state.query.copyWith(page: page);
    await loadOldStock(newQuery: newQuery, isGoToPage: true);
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

  // Filter and search methods
  void search(String? searchValue) {
    final newQuery = state.query.copyWith(search: searchValue, page: 1);
    loadOldStock(newQuery: newQuery, refresh: true);
  }

  void sort(String? sort, String? order) {
    final newQuery = state.query.copyWith(sort: sort, order: order, page: 1);
    loadOldStock(newQuery: newQuery, refresh: true);
  }

  void filterByCategory(int? categoryID) {
    final newQuery = state.query.copyWith(categoryID: categoryID, page: 1);
    loadOldStock(newQuery: newQuery, refresh: true);
  }

  void applyFilter({
    String? search,
    String? sort,
    String? order,
    int? categoryID,
    int? limit,
  }) {
    final newQuery = state.query.copyWith(
      search: search,
      sort: sort,
      order: order,
      categoryID: categoryID,
      limit: limit,
      page: 1,
    );
    loadOldStock(newQuery: newQuery, refresh: true);
  }

  void clearFilter() {
    const newQuery = OldStockQuery(page: 1);
    loadOldStock(newQuery: newQuery, refresh: true);
  }

  void loadMore() {
    loadOldStock(isLoadMore: true);
  }

  void refresh() {
    loadOldStock(refresh: true);
  }
}
