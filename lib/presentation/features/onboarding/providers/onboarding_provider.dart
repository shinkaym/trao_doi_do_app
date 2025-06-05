import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';
import 'package:trao_doi_do_app/data/datasources/local/onboarding_local_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/onboarding_repository_impl.dart';
import 'package:trao_doi_do_app/domain/usecases/onboarding_usecase.dart';

// Create a cached provider for better performance
final _onboardingBoxProvider = Provider<Box>((ref) {
  return Hive.box(StorageKeys.settings);
});

final _onboardingDataSourceProvider = Provider<OnboardingLocalDataSource>((
  ref,
) {
  final box = ref.watch(_onboardingBoxProvider);
  return OnboardingLocalDataSourceImpl(box);
});

final _onboardingRepositoryProvider = Provider<OnboardingRepositoryImpl>((ref) {
  final dataSource = ref.watch(_onboardingDataSourceProvider);
  return OnboardingRepositoryImpl(dataSource);
});

final onboardingUseCaseProvider = Provider<OnboardingUseCase>((ref) {
  final repository = ref.watch(_onboardingRepositoryProvider);
  return OnboardingUseCase(repository);
});

// State provider for onboarding completion status
final onboardingStateProvider = StateProvider<bool>((ref) {
  final useCase = ref.watch(onboardingUseCaseProvider);
  return useCase.isCompleted();
});

// Computed provider to watch the state
final isOnboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(onboardingStateProvider);
});

// Action provider for completing onboarding
final completeOnboardingProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final useCase = ref.read(onboardingUseCaseProvider);
    await useCase.complete();
    // Update the state after completion
    ref.read(onboardingStateProvider.notifier).state = true;
  };
});
