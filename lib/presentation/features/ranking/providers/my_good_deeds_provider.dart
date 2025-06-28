import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';
import 'package:trao_doi_do_app/domain/usecases/get_my_good_deeds_usecase.dart';

class MyGoodDeedsState {
  final bool isLoading;
  final List<MyGoodDeed> goodDeeds;
  final Failure? failure;

  MyGoodDeedsState({
    this.isLoading = false,
    this.goodDeeds = const [],
    this.failure,
  });

  MyGoodDeedsState copyWith({
    bool? isLoading,
    List<MyGoodDeed>? goodDeeds,
    Failure? failure,
  }) {
    return MyGoodDeedsState(
      isLoading: isLoading ?? this.isLoading,
      goodDeeds: goodDeeds ?? this.goodDeeds,
      failure: failure,
    );
  }
}

class MyGoodDeedsNotifier extends StateNotifier<MyGoodDeedsState> {
  final GetMyGoodDeedsUseCase _getMyGoodDeedsUseCase;

  MyGoodDeedsNotifier(this._getMyGoodDeedsUseCase) : super(MyGoodDeedsState());

  Future<void> loadMyGoodDeeds() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    final result = await _getMyGoodDeedsUseCase();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (goodDeedsResponse) {
        state = state.copyWith(
          isLoading: false,
          goodDeeds: goodDeedsResponse.goodDeeds,
        );
      },
    );
  }

  void refresh() {
    loadMyGoodDeeds();
  }

  void clearGoodDeeds() {
    state = MyGoodDeedsState();
  }
}
