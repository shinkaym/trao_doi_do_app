import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/item.dart';
import 'package:trao_doi_do_app/domain/usecases/params/item_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_items_usecase.dart';

class ItemsListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Item> items;
  final int currentPage;
  final int totalPage;
  final ItemsQuery query;
  final Failure? failure;
  final bool hasMoreData;

  ItemsListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.items = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const ItemsQuery(),
    this.failure,
    this.hasMoreData = true,
  });

  ItemsListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Item>? items,
    int? currentPage,
    int? totalPage,
    ItemsQuery? query,
    Failure? failure,
    bool? hasMoreData,
  }) {
    return ItemsListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class ItemsListNotifier extends StateNotifier<ItemsListState> {
  final GetItemsUseCase _getItemsUseCase;

  ItemsListNotifier(this._getItemsUseCase) : super(ItemsListState());

  // Load items with refresh option
  Future<void> loadItems({ItemsQuery? newQuery, bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.items.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
      );
    } else {
      // Load more
      if (!state.hasMoreData || state.currentPage >= state.totalPage) return;

      state = state.copyWith(
        isLoadingMore: true,
        failure: null,
        query: query.copyWith(page: state.currentPage + 1),
      );
    }

    final result = await _getItemsUseCase(state.query);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            failure: failure,
          ),
      (itemsResult) {
        final newItems =
            isFirstLoad
                ? itemsResult.items
                : [...state.items, ...itemsResult.items];

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          items: newItems,
          currentPage: state.query.page,
          totalPage: itemsResult.totalPage,
          hasMoreData: state.query.page < itemsResult.totalPage,
        );
      },
    );
  }

  // Filter methods
  void filterByCategory(int? categoryID) {
    final newQuery = state.query.copyWith(categoryID: categoryID);
    loadItems(newQuery: newQuery, refresh: true);
  }

  void search(String? searchBy, String? searchValue) {
    final newQuery = state.query.copyWith(
      searchBy: searchBy,
      searchValue: searchValue,
    );
    loadItems(newQuery: newQuery, refresh: true);
  }

  void sortItems(String? sort, String? order) {
    final newQuery = state.query.copyWith(sort: sort, order: order);
    loadItems(newQuery: newQuery, refresh: true);
  }

  void loadMore() {
    loadItems();
  }

  void refresh() {
    loadItems(refresh: true);
  }

  void clearFilters() {
    final newQuery = const ItemsQuery();
    loadItems(newQuery: newQuery, refresh: true);
  }
}
