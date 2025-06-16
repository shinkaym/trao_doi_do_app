import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';
import 'package:trao_doi_do_app/domain/usecases/onboarding_usecase.dart';

class OnboardingState {
  final bool isCompleted;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    bool? isCompleted,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          isCompleted == other.isCompleted &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      isCompleted.hashCode ^ isLoading.hashCode ^ error.hashCode;
}

/// Onboarding Notifier với error handling
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OnboardingUseCase _useCase;
  final ILogger _logger;

  OnboardingNotifier(this._useCase, this._logger) : super(OnboardingState()) {
    _initializeState();
  }

  void _initializeState() {
    try {
      final isCompleted = _useCase.isCompleted();
      state = state.copyWith(isCompleted: isCompleted);
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize onboarding state', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> completeOnboarding() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _useCase.complete();
      state = state.copyWith(isCompleted: true, isLoading: false);
      _logger.i('Onboarding completed successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to complete onboarding', e, stackTrace);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}
