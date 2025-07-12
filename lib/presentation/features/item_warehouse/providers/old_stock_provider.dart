import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';
import 'package:trao_doi_do_app/domain/usecases/get_old_stock_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/params/old_stock_query.dart';

class OldStockState {
  final bool isLoading;
  final bool isLoadingPage;
  final List<OldStockItem> items;
  final int currentPage;
  final int totalPage;
  final OldStockQuery query;
  final Failure? failure;
  final bool hasMoreData;

  OldStockState({
    this.isLoading = false,
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

  int? _currentRequestId;
  int _nextRequestId = 1;

  OldStockNotifier(this._getOldStockUseCase) : super(OldStockState());

  Future<void> loadOldStock({
    OldStockQuery? newQuery,
    bool refresh = false,
  }) async {
    if (state.isLoading || state.isLoadingPage) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.items.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
      );
    }

    final result = await _getOldStockUseCase(state.query);
    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingPage: false,
            failure: failure,
          ),
      (oldStockResponse) {
        List<OldStockItem> newItems;

        if (isFirstLoad) {
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

    // Tạo requestId mới
    final requestId = _nextRequestId++;
    _currentRequestId = requestId;

    // Cập nhật UI ngay lập tức
    state = state.copyWith(currentPage: page, isLoadingPage: true);

    final newQuery = state.query.copyWith(page: page);

    try {
      final result = await _getOldStockUseCase(newQuery);

      // Kiểm tra request có còn là mới nhất không
      if (_currentRequestId != requestId) return;

      result.fold(
        (failure) =>
            state = state.copyWith(failure: failure, isLoadingPage: false),
        (oldStockResponse) {
          final actualTotalPage = oldStockResponse.totalPage;
          final actualHasMoreData =
              actualTotalPage > 0 && page < actualTotalPage;

          state = state.copyWith(
            items: oldStockResponse.itemOldStocks,
            totalPage: actualTotalPage,
            hasMoreData: actualHasMoreData,
            failure: null,
            isLoadingPage: false,
          );
        },
      );
    } catch (e) {
      if (_currentRequestId != requestId) return;
      state = state.copyWith(isLoadingPage: false);
    }
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

  void refresh() {
    loadOldStock(refresh: true);
  }
}
