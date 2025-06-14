import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

/// Enhanced Splash State với progress tracking
class SplashState {
  final bool isCompleted;
  final bool isLoading;
  final String? error;
  final Duration duration;
  final double progress; // Thêm progress tracking

  const SplashState({
    this.isCompleted = false,
    this.isLoading = true,
    this.error,
    this.duration = const Duration(seconds: 3), // Tăng lên 3 giây
    this.progress = 0.0,
  });

  SplashState copyWith({
    bool? isCompleted,
    bool? isLoading,
    String? error,
    Duration? duration,
    double? progress,
  }) {
    return SplashState(
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashState &&
          runtimeType == other.runtimeType &&
          isCompleted == other.isCompleted &&
          isLoading == other.isLoading &&
          error == other.error &&
          duration == other.duration &&
          progress == other.progress;

  @override
  int get hashCode =>
      isCompleted.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      duration.hashCode ^
      progress.hashCode;
}

/// Enhanced Splash Notifier với progress tracking
class SplashNotifier extends StateNotifier<SplashState> {
  final ILogger _logger;

  SplashNotifier(this._logger) : super(const SplashState());

  Future<void> startSplash({Duration? customDuration}) async {
    if (!mounted) return;

    final duration = customDuration ?? state.duration;
    state = state.copyWith(
      isLoading: true,
      isCompleted: false,
      error: null,
      progress: 0.0,
    );

    try {
      // Tạo progress animation trong khoảng thời gian splash
      const updateInterval = Duration(milliseconds: 50);
      final totalSteps =
          duration.inMilliseconds ~/ updateInterval.inMilliseconds;

      for (int i = 0; i <= totalSteps; i++) {
        if (!mounted) return;

        final currentProgress = i / totalSteps;
        state = state.copyWith(progress: currentProgress);

        if (i < totalSteps) {
          await Future.delayed(updateInterval);
        }
      }

      // Đảm bảo progress = 1.0 và completed = true cùng lúc
      if (mounted) {
        state = state.copyWith(
          isCompleted: true,
          isLoading: false,
          progress: 1.0,
        );
        _logger.i(
          'Splash completed successfully with progress: ${state.progress}',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Splash error', e, stackTrace);
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void updateProgress(double progress) {
    if (mounted && progress >= 0.0 && progress <= 1.0) {
      state = state.copyWith(progress: progress);

      // Auto complete khi progress đạt 100%
      if (progress >= 1.0 && !state.isCompleted) {
        state = state.copyWith(isCompleted: true, isLoading: false);
      }
    }
  }

  void completeSplash() {
    if (mounted) {
      state = state.copyWith(
        isCompleted: true,
        isLoading: false,
        progress: 1.0,
      );
    }
  }

  void reset() {
    if (mounted) {
      state = const SplashState();
    }
  }
}

/// Enhanced Splash Providers
final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>((
  ref,
) {
  final logger = ref.watch(loggerProvider);
  return SplashNotifier(logger);
});

final isSplashCompletedProvider = Provider<bool>((ref) {
  return ref.watch(splashProvider.select((state) => state.isCompleted));
});

final isSplashLoadingProvider = Provider<bool>((ref) {
  return ref.watch(splashProvider.select((state) => state.isLoading));
});

final splashErrorProvider = Provider<String?>((ref) {
  return ref.watch(splashProvider.select((state) => state.error));
});

final splashProgressProvider = Provider<double>((ref) {
  return ref.watch(splashProvider.select((state) => state.progress));
});

// Provider để check cả progress và completion
final isSplashReadyProvider = Provider<bool>((ref) {
  final state = ref.watch(splashProvider);
  return state.progress >= 1.0 && state.isCompleted;
});
