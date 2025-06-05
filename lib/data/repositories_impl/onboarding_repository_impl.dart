import 'package:trao_doi_do_app/data/datasources/local/onboarding_local_datasource.dart';
import 'package:trao_doi_do_app/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;

  OnboardingRepositoryImpl(this._localDataSource);

  @override
  Future<void> setOnboardingCompleted() => _localDataSource.setCompleted(true);

  @override
  bool isOnboardingCompleted() => _localDataSource.isCompleted();
}
