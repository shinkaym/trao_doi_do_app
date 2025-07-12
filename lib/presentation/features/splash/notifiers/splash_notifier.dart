import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

/// Enhanced Splash State với progress tracking
class SplashState {
  final bool isCompleted;
  final bool isLoading;
  final String? error;
  final Duration duration;
  final double progress;
  final SplashPhase currentPhase;

  const SplashState({
    this.isCompleted = false,
    this.isLoading = true,
    this.error,
    this.duration = const Duration(milliseconds: 4000),
    this.progress = 0.0,
    this.currentPhase = SplashPhase.initializing,
  });

  SplashState copyWith({
    bool? isCompleted,
    bool? isLoading,
    String? error,
    Duration? duration,
    double? progress,
    SplashPhase? currentPhase,
  }) {
    return SplashState(
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      currentPhase: currentPhase ?? this.currentPhase,
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
          progress == other.progress &&
          currentPhase == other.currentPhase;

  @override
  int get hashCode =>
      isCompleted.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      duration.hashCode ^
      progress.hashCode ^
      currentPhase.hashCode;
}

/// Splash phases for better tracking
enum SplashPhase {
  initializing,
  loadingAssets,
  loadingData,
  preparingApp,
  completing,
  completed,
}

/// Enhanced Splash Notifier với smooth progress tracking
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
      currentPhase: SplashPhase.initializing,
    );

    try {
      await _runSplashSequence(duration);
    } catch (e, stackTrace) {
      _logger.e('Splash error', e, stackTrace);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
          currentPhase: SplashPhase.completed,
        );
      }
    }
  }

  Future<void> _runSplashSequence(Duration totalDuration) async {
    const stepDuration = Duration(milliseconds: 40);
    
    // Phase 1: Initializing (0-20%)
    await _runPhase(
      SplashPhase.initializing,
      startProgress: 0.0,
      endProgress: 0.2,
      stepCount: 20,
      stepDuration: stepDuration,
    );

    // Phase 2: Loading Assets (20-50%)
    await _runPhase(
      SplashPhase.loadingAssets,
      startProgress: 0.2,
      endProgress: 0.5,
      stepCount: 30,
      stepDuration: stepDuration,
    );

    // Phase 3: Loading Data (50-80%)
    await _runPhase(
      SplashPhase.loadingData,
      startProgress: 0.5,
      endProgress: 0.8,
      stepCount: 30,
      stepDuration: stepDuration,
    );

    // Phase 4: Preparing App (80-95%)
    await _runPhase(
      SplashPhase.preparingApp,
      startProgress: 0.8,
      endProgress: 0.95,
      stepCount: 15,
      stepDuration: stepDuration,
    );

    // Phase 5: Completing (95-100%)
    await _runPhase(
      SplashPhase.completing,
      startProgress: 0.95,
      endProgress: 1.0,
      stepCount: 5,
      stepDuration: stepDuration,
    );

    // Final completion
    if (mounted) {
      state = state.copyWith(
        isCompleted: true,
        isLoading: false,
        progress: 1.0,
        currentPhase: SplashPhase.completed,
      );
      _logger.i(
        'Splash completed successfully with progress: ${state.progress}',
      );
    }
  }

  Future<void> _runPhase(
    SplashPhase phase, {
    required double startProgress,
    required double endProgress,
    required int stepCount,
    required Duration stepDuration,
  }) async {
    if (!mounted) return;

    // Set current phase
    state = state.copyWith(currentPhase: phase);

    final progressRange = endProgress - startProgress;
    final progressPerStep = progressRange / stepCount;

    for (int i = 0; i <= stepCount; i++) {
      if (!mounted) return;

      final currentProgress = startProgress + (progressPerStep * i);
      state = state.copyWith(progress: currentProgress.clamp(0.0, 1.0));

      if (i < stepCount) {
        await Future.delayed(stepDuration);
      }
    }
  }

  void updateProgress(double progress) {
    if (mounted && progress >= 0.0 && progress <= 1.0) {
      state = state.copyWith(progress: progress);

      // Auto complete khi progress đạt 100%
      if (progress >= 1.0 && !state.isCompleted) {
        state = state.copyWith(
          isCompleted: true,
          isLoading: false,
          currentPhase: SplashPhase.completed,
        );
      }
    }
  }

  void setPhase(SplashPhase phase) {
    if (mounted) {
      state = state.copyWith(currentPhase: phase);
    }
  }

  void completeSplash() {
    if (mounted) {
      state = state.copyWith(
        isCompleted: true,
        isLoading: false,
        progress: 1.0,
        currentPhase: SplashPhase.completed,
      );
    }
  }

  void reset() {
    if (mounted) {
      state = const SplashState();
    }
  }

  // Getter cho phase description
  String get currentPhaseDescription {
    switch (state.currentPhase) {
      case SplashPhase.initializing:
        return 'Đang khởi tạo...';
      case SplashPhase.loadingAssets:
        return 'Đang tải tài nguyên...';
      case SplashPhase.loadingData:
        return 'Đang tải dữ liệu...';
      case SplashPhase.preparingApp:
        return 'Đang chuẩn bị ứng dụng...';
      case SplashPhase.completing:
        return 'Hoàn tất...';
      case SplashPhase.completed:
        return 'Hoàn thành!';
    }
  }
}
