import 'package:hive/hive.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';

abstract class OnboardingLocalDataSource {
  Future<void> setCompleted(bool value);
  bool isCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final Box _box;

  OnboardingLocalDataSourceImpl(this._box);

  @override
  Future<void> setCompleted(bool value) async {
    await _box.put(StorageKeys.onboardingCompleted, value);
  }

  @override
  bool isCompleted() {
    return _box.get(StorageKeys.onboardingCompleted, defaultValue: false);
  }
}
