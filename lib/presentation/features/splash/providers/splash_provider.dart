import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class for splash
class SplashState {
  final bool isCompleted;
  final bool isLoading;

  const SplashState({
    this.isCompleted = false,
    this.isLoading = true,
  });

  SplashState copyWith({
    bool? isCompleted,
    bool? isLoading,
  }) {
    return SplashState(
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashState &&
          runtimeType == other.runtimeType &&
          isCompleted == other.isCompleted &&
          isLoading == other.isLoading;

  @override
  int get hashCode => isCompleted.hashCode ^ isLoading.hashCode;

  @override
  String toString() => 'SplashState(isCompleted: $isCompleted, isLoading: $isLoading)';
}

// Splash notifier with better state management
class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier() : super(const SplashState());

  void startSplash() {
    if (mounted) {
      state = state.copyWith(isLoading: true, isCompleted: false);
    }
  }

  void completeSplash() {
    if (mounted) {
      state = state.copyWith(isCompleted: true, isLoading: false);
    }
  }

  void reset() {
    if (mounted) {
      state = const SplashState();
    }
  }
}

// Provider instances
final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  return SplashNotifier();
});

// Separate provider to prevent unnecessary rebuilds
final isSplashCompletedProvider = Provider<bool>((ref) {
  return ref.watch(splashProvider.select((state) => state.isCompleted));
});

// Provider for loading state
final isSplashLoadingProvider = Provider<bool>((ref) {
  return ref.watch(splashProvider.select((state) => state.isLoading));
});