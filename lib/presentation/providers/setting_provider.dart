import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/setting.dart';
import 'package:trao_doi_do_app/domain/usecases/get_setting_by_key_usecase.dart';

class SettingState {
  final bool isLoading;
  final Setting? setting;
  final Failure? failure;

  SettingState({this.isLoading = false, this.setting, this.failure});

  SettingState copyWith({bool? isLoading, Setting? setting, Failure? failure}) {
    return SettingState(
      isLoading: isLoading ?? this.isLoading,
      setting: setting ?? this.setting,
      failure: failure,
    );
  }
}

class SettingNotifier extends StateNotifier<SettingState> {
  final GetSettingByKeyUseCase _getSettingByKeyUseCase;
  final String settingKey;

  SettingNotifier(this._getSettingByKeyUseCase, this.settingKey)
    : super(SettingState());

  Future<void> loadSetting() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    final result = await _getSettingByKeyUseCase(settingKey);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (settingResponse) {
        state = state.copyWith(
          isLoading: false,
          setting: settingResponse.setting,
        );
      },
    );
  }

  void clearFailure() {
    state = state.copyWith(failure: null);
  }

  void refresh() {
    loadSetting();
  }
}
