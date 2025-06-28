import 'package:trao_doi_do_app/domain/entities/setting.dart';

class SettingModel {
  final int id;
  final String key;
  final String value;

  const SettingModel({
    required this.id,
    required this.key,
    required this.value,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      id: json['id'] as int,
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'key': key, 'value': value};
  }

  Setting toEntity() {
    return Setting(id: id, key: key, value: value);
  }

  factory SettingModel.fromEntity(Setting entity) {
    return SettingModel(id: entity.id, key: entity.key, value: entity.value);
  }
}
