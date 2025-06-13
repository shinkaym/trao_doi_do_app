import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/domain/usecases/create_interest_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/cancel_interest_usecase.dart';

class InterestState {
  final bool isLoading;
  final Failure? failure;
  final InterestActionResult? result;

  InterestState({this.isLoading = false, this.failure, this.result});

  InterestState copyWith({
    bool? isLoading,
    Failure? failure,
    InterestActionResult? result,
  }) {
    return InterestState(
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      result: result,
    );
  }
}

class InterestNotifier extends StateNotifier<InterestState> {
  final CreateInterestUseCase _createInterestUseCase;
  final CancelInterestUseCase _cancelInterestUseCase;

  InterestNotifier(this._createInterestUseCase, this._cancelInterestUseCase)
    : super(InterestState());

  Future<void> createInterest(int postID) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null, result: null);

    final result = await _createInterestUseCase(postID);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (actionResult) {
        state = state.copyWith(isLoading: false, result: actionResult);
      },
    );
  }

  Future<void> cancelInterest(int postID) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null, result: null);

    final result = await _cancelInterestUseCase(postID);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (actionResult) {
        state = state.copyWith(isLoading: false, result: actionResult);
      },
    );
  }

  Future<void> toggleInterest(int postID, InterestAction action) async {
    switch (action) {
      case InterestAction.create:
        await createInterest(postID);
        break;
      case InterestAction.cancel:
        await cancelInterest(postID);
        break;
    }
  }

  void clearMessages() {
    state = state.copyWith(failure: null, result: null);
  }
}

final interestProvider = StateNotifierProvider<InterestNotifier, InterestState>(
  (ref) {
    final createInterestUseCase = ref.watch(createInterestUseCaseProvider);
    final cancelInterestUseCase = ref.watch(cancelInterestUseCaseProvider);
    return InterestNotifier(createInterestUseCase, cancelInterestUseCase);
  },
);
