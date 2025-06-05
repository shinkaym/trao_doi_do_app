import 'package:trao_doi_do_app/domain/repositories/onboarding_repository.dart';

class OnboardingUseCase {
  final OnboardingRepository repository;

  OnboardingUseCase(this.repository);

  Future<void> complete() => repository.setOnboardingCompleted();

  bool isCompleted() => repository.isOnboardingCompleted();
}
