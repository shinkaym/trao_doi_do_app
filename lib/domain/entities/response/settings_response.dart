import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/setting.dart';

class SettingsResponse extends Equatable {
  final List<Setting> settings;

  const SettingsResponse({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class SettingResponse extends Equatable {
  final Setting setting;

  const SettingResponse({required this.setting});

  @override
  List<Object?> get props => [setting];
}
