import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interests_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_interests_usecase.dart';

class InterestsListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<InterestPost> interests;
  final int currentPage;
  final int totalPage;
  final InterestsQuery query;
  final Failure? failure;
  final bool hasMoreData;
  final bool isLoadingPage;

  InterestsListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.interests = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const InterestsQuery(order: 'DESC'),
    this.failure,
    this.hasMoreData = true,
    this.isLoadingPage = false,
  });

  InterestsListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<InterestPost>? interests,
    int? currentPage,
    int? totalPage,
    InterestsQuery? query,
    Failure? failure,
    bool? hasMoreData,
    bool? isLoadingPage,
  }) {
    return InterestsListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      interests: interests ?? this.interests,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
    );
  }
}

class InterestsListNotifier extends StateNotifier<InterestsListState> {
  final GetInterestsUseCase _getInterestsUseCase;

  InterestsListNotifier(this._getInterestsUseCase)
    : super(InterestsListState());

  Future<void> loadInterests({
    InterestsQuery? newQuery,
    bool refresh = false,
    bool isLoadMore = false,
    bool isGoToPage = false,
  }) async {
    // Ngăn chặn multiple calls cùng lúc
    if (state.isLoading || state.isLoadingMore || state.isLoadingPage) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.interests.isEmpty;
    final isTypeChanged = newQuery != null && newQuery.type != state.query.type;

    // Nếu type thay đổi, luôn load từ đầu
    if (isTypeChanged || isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
        interests: [], // Clear data khi type thay đổi
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

    try {
      final result = await _getInterestsUseCase(state.query);

      result.fold(
        (failure) =>
            state = state.copyWith(
              isLoading: false,
              isLoadingMore: false,
              isLoadingPage: false,
              failure: failure,
            ),
        (interestsResult) {
          List<InterestPost> newInterests;

          if (isTypeChanged || isFirstLoad) {
            newInterests = interestsResult.interests;
          } else if (isLoadMore) {
            newInterests = [...state.interests, ...interestsResult.interests];
          } else if (isGoToPage) {
            newInterests = interestsResult.interests;
          } else {
            newInterests = state.interests;
          }

          final actualTotalPage = interestsResult.totalPage;
          final actualCurrentPage = actualTotalPage > 0 ? state.query.page : 1;
          final actualHasMoreData =
              actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            isLoadingPage: false,
            interests: newInterests,
            currentPage: actualCurrentPage,
            totalPage: actualTotalPage,
            hasMoreData: actualHasMoreData,
            failure: null, // Clear failure khi success
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        isLoadingPage: false,
        failure: ServerFailure('Đã xảy ra lỗi không mong muốn'),
      );
    }
  }

  // Pagination methods
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPage || page == state.currentPage) return;
    final newQuery = state.query.copyWith(page: page);
    await loadInterests(newQuery: newQuery, isGoToPage: true);
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

  // Filter methods
  void filterByType(int? type) {
    final newQuery = state.query.copyWith(type: type, page: 1);
    loadInterests(newQuery: newQuery, refresh: true);
  }

  void search(String? search) {
    final newQuery = state.query.copyWith(search: search, page: 1);
    loadInterests(newQuery: newQuery, refresh: true);
  }

  void sortInterests(String? sort, String? order) {
    final newQuery = state.query.copyWith(sort: sort, order: order, page: 1);
    loadInterests(newQuery: newQuery, refresh: true);
  }

  void loadMore() {
    loadInterests(isLoadMore: true);
  }

  void refresh() {
    loadInterests(refresh: true);
  }
}
