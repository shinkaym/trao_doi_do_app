import 'package:trao_doi_do_app/data/models/setting_model.dart';
import 'package:trao_doi_do_app/domain/entities/response/settings_response.dart';

class SettingsResponseModel {
  final List<SettingModel> settings;

  const SettingsResponseModel({required this.settings});

  factory SettingsResponseModel.fromJson(Map<String, dynamic> json) {
    return SettingsResponseModel(
      settings:
          (json['settings'] as List<dynamic>)
              .map(
                (setting) =>
                    SettingModel.fromJson(setting as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'settings': settings.map((setting) => setting.toJson()).toList()};
  }

  SettingsResponse toEntity() {
    return SettingsResponse(
      settings: settings.map((setting) => setting.toEntity()).toList(),
    );
  }

  factory SettingsResponseModel.fromEntity(SettingsResponse entity) {
    return SettingsResponseModel(
      settings:
          entity.settings
              .map((setting) => SettingModel.fromEntity(setting))
              .toList(),
    );
  }
}

class SettingResponseModel {
  final SettingModel setting;

  const SettingResponseModel({required this.setting});

  factory SettingResponseModel.fromJson(Map<String, dynamic> json) {
    return SettingResponseModel(
      setting: SettingModel.fromJson(json['setting'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'setting': setting.toJson()};
  }

  SettingResponse toEntity() {
    return SettingResponse(setting: setting.toEntity());
  }

  factory SettingResponseModel.fromEntity(SettingResponse entity) {
    return SettingResponseModel(
      setting: SettingModel.fromEntity(entity.setting),
    );
  }
}
