import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/settings_response.dart';

abstract class SettingsRepository {
  Future<Either<Failure, SettingsResponse>> getSettings();
  Future<Either<Failure, SettingResponse>> getSettingByKey(String settingKey);
}
