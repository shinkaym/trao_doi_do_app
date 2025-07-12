import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/setting.dart';
import 'package:trao_doi_do_app/domain/usecases/get_settings_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_setting_by_key_usecase.dart';

class SettingsState {
  final bool isLoading;
  final List<Setting> settings;
  final Failure? failure;

  SettingsState({
    this.isLoading = false,
    this.settings = const [],
    this.failure,
  });

  SettingsState copyWith({
    bool? isLoading,
    List<Setting>? settings,
    Failure? failure,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      failure: failure,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final GetSettingsUseCase _getSettingsUseCase;
  final GetSettingByKeyUseCase _getSettingByKeyUseCase;

  SettingsNotifier(this._getSettingsUseCase, this._getSettingByKeyUseCase)
    : super(SettingsState());

  Future<void> loadSettings() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    final result = await _getSettingsUseCase();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (settingsResponse) {
        state = state.copyWith(
          isLoading: false,
          settings: settingsResponse.settings,
        );
      },
    );
  }

  Future<Setting?> getSettingByKey(String key) async {
    final result = await _getSettingByKeyUseCase(key);

    return result.fold((failure) {
      state = state.copyWith(failure: failure);
      return null;
    }, (settingResponse) => settingResponse.setting);
  }

  Setting? findSettingByKey(String key) {
    try {
      return state.settings.firstWhere((setting) => setting.key == key);
    } catch (e) {
      return null;
    }
  }

  void clearFailure() {
    state = state.copyWith(failure: null);
  }

  void refresh() {
    loadSettings();
  }
}
