import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/item.dart';
import 'package:trao_doi_do_app/domain/usecases/get_items_usecase.dart';

class ItemState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Item> items;
  final Failure? failure;
  final int currentPage;
  final bool hasMoreData;
  final String? sort;
  final String? order;
  final String? searchBy;
  final String? searchValue;

  ItemState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.items = const [],
    this.failure,
    this.currentPage = 1,
    this.hasMoreData = true,
    this.sort,
    this.order,
    this.searchBy,
    this.searchValue,
  });

  ItemState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Item>? items,
    Failure? failure,
    int? currentPage,
    bool? hasMoreData,
    String? sort,
    String? order,
    String? searchBy,
    String? searchValue,
  }) {
    return ItemState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      items: items ?? this.items,
      failure: failure,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      searchBy: searchBy ?? this.searchBy,
      searchValue: searchValue ?? this.searchValue,
    );
  }
}

class ItemNotifier extends StateNotifier<ItemState> {
  final GetItemsUseCase _getItemsUseCase;

  ItemNotifier(this._getItemsUseCase) : super(ItemState());

  Future<void> getItems({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        currentPage: 1,
        hasMoreData: true,
        items: [],
      );
    } else if (state.isLoading || state.isLoadingMore || !state.hasMoreData) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true, failure: null);
    }

    final result = await _getItemsUseCase(
      page: refresh ? 1 : state.currentPage,
      sort: state.sort,
      order: state.order,
      searchBy: state.searchBy,
      searchValue: state.searchValue,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            failure: failure,
          ),
      (itemsResponse) {
        final newItems =
            refresh
                ? itemsResponse.items
                : [...state.items, ...itemsResponse.items];

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          items: newItems,
          currentPage: refresh ? 2 : state.currentPage + 1,
          hasMoreData: state.currentPage < itemsResponse.totalPage,
        );
      },
    );
  }

  // Updated method for sorting
  void setSortOptions({String? sort, String? order}) {
    state = state.copyWith(sort: sort, order: order);
    getItems(refresh: true);
  }

  // Updated method for searching
  void setSearchOptions({String? searchBy, String? searchValue}) {
    state = state.copyWith(searchBy: searchBy, searchValue: searchValue);
    getItems(refresh: true);
  }

  // Clear all filters
  void clearFilters() {
    state = state.copyWith(
      sort: null,
      order: null,
      searchBy: null,
      searchValue: null,
    );
    getItems(refresh: true);
  }
}

final itemProvider = StateNotifierProvider<ItemNotifier, ItemState>((ref) {
  final getItemsUseCase = ref.watch(getItemsUseCaseProvider);
  return ItemNotifier(getItemsUseCase);
});
