import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';
import 'package:trao_doi_do_app/domain/usecases/get_user_ranks_usecase.dart';

class RankingState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<UserRank> userRanks;
  final UserRank? yourInfo;
  final int yourRank;
  final int currentPage;
  final int totalPage;
  final Failure? failure;
  final bool hasMoreData;

  RankingState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.userRanks = const [],
    this.yourInfo,
    this.yourRank = 0,
    this.currentPage = 1,
    this.totalPage = 1,
    this.failure,
    this.hasMoreData = true,
  });

  RankingState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<UserRank>? userRanks,
    UserRank? yourInfo,
    int? yourRank,
    int? currentPage,
    int? totalPage,
    Failure? failure,
    bool? hasMoreData,
  }) {
    return RankingState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      userRanks: userRanks ?? this.userRanks,
      yourInfo: yourInfo ?? this.yourInfo,
      yourRank: yourRank ?? this.yourRank,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class RankingNotifier extends StateNotifier<RankingState> {
  final GetUserRanksUseCase _getUserRanksUseCase;
  static const int _limit = 20;

  RankingNotifier(this._getUserRanksUseCase) : super(RankingState());

  Future<void> loadRanking({bool refresh = false}) async {
    // Prevent multiple simultaneous requests
    if (state.isLoading || state.isLoadingMore) return;

    final isFirstLoad = refresh || state.userRanks.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(isLoading: true, failure: null, currentPage: 1);
    } else {
      // Load more case
      if (!state.hasMoreData || state.currentPage >= state.totalPage) return;

      state = state.copyWith(isLoadingMore: true, failure: null);
    }

    final page = isFirstLoad ? 1 : state.currentPage + 1;
    final result = await _getUserRanksUseCase(page, _limit);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            failure: failure,
          ),
      (rankingResponse) {
        List<UserRank> newUserRanks;

        if (isFirstLoad) {
          newUserRanks = rankingResponse.userRanks;
        } else {
          newUserRanks = [...state.userRanks, ...rankingResponse.userRanks];
        }

        final actualCurrentPage = page;
        final actualTotalPage = rankingResponse.totalPage;
        final actualHasMoreData = actualCurrentPage < actualTotalPage;

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          userRanks: newUserRanks,
          yourInfo: rankingResponse.yourInfo,
          yourRank: rankingResponse.yourRank,
          currentPage: actualCurrentPage,
          totalPage: actualTotalPage,
          hasMoreData: actualHasMoreData,
        );
      },
    );
  }

  void loadMore() {
    loadRanking(refresh: false);
  }

  void refresh() {
    loadRanking(refresh: true);
  }

  void clearRanking() {
    state = RankingState();
  }
}
