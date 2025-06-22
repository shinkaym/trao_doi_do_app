import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/usecases/get_unread_count_usecase.dart';

class UnreadCountState {
  final bool isLoading;
  final int count;
  final Failure? failure;

  UnreadCountState({this.isLoading = false, this.count = 0, this.failure});

  UnreadCountState copyWith({bool? isLoading, int? count, Failure? failure}) {
    return UnreadCountState(
      isLoading: isLoading ?? this.isLoading,
      count: count ?? this.count,
      failure: failure,
    );
  }
}

class UnreadCountNotifier extends StateNotifier<UnreadCountState> {
  final GetUnreadCountUseCase _getUnreadCountUseCase;

  UnreadCountNotifier(this._getUnreadCountUseCase) : super(UnreadCountState());

  Future<void> loadUnreadCount() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    try {
      final result = await _getUnreadCountUseCase();

      result.fold(
        (failure) => state = state.copyWith(isLoading: false, failure: failure),
        (count) => state = state.copyWith(isLoading: false, count: count),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure('Đã xảy ra lỗi không mong muốn'),
      );
    }
  }

  void updateCount(int count) {
    state = state.copyWith(count: count);
  }

  void decreaseCount(int amount) {
    final newCount = (state.count - amount).clamp(0, double.infinity).toInt();
    state = state.copyWith(count: newCount);
  }

  void markAllAsRead() {
    state = state.copyWith(count: 0);
  }
}
