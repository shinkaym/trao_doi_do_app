import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/usecases/get_interest_detail_usecase.dart';

class InterestDetailState {
  final bool isLoading;
  final InterestPost? interestDetail;
  final Failure? failure;

  InterestDetailState({
    this.isLoading = false,
    this.interestDetail,
    this.failure,
  });

  InterestDetailState copyWith({
    bool? isLoading,
    InterestPost? interestDetail,
    Failure? failure,
  }) {
    return InterestDetailState(
      isLoading: isLoading ?? this.isLoading,
      interestDetail: interestDetail ?? this.interestDetail,
      failure: failure,
    );
  }
}

class InterestDetailNotifier extends StateNotifier<InterestDetailState> {
  final GetInterestDetailUseCase _getInterestDetailUseCase;

  InterestDetailNotifier(this._getInterestDetailUseCase)
    : super(InterestDetailState());

  Future<void> loadInterestDetail(int interestID) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    final result = await _getInterestDetailUseCase(interestID);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (interestDetail) =>
          state = state.copyWith(
            isLoading: false,
            interestDetail: interestDetail,
            failure: null,
          ),
    );
  }

  void clearError() {
    state = state.copyWith(failure: null);
  }

  void reset() {
    state = InterestDetailState();
  }
}
