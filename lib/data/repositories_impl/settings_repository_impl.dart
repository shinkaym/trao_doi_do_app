import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/settings_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/response/settings_response.dart';
import 'package:trao_doi_do_app/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;

  SettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, SettingsResponse>> getSettings() async {
    return handleRepositoryCall<SettingsResponse>(() async {
      final remoteResponse = await _remoteDataSource.getSettings();
      final settingsEntity = remoteResponse.toEntity();
      return settingsEntity;
    }, 'Lỗi tải danh sách cài đặt');
  }

  @override
  Future<Either<Failure, SettingResponse>> getSettingByKey(
    String settingKey,
  ) async {
    return handleRepositoryCall<SettingResponse>(() async {
      final remoteResponse = await _remoteDataSource.getSettingByKey(
        settingKey,
      );
      final settingEntity = remoteResponse.toEntity();
      return settingEntity;
    }, 'Lỗi tải cài đặt');
  }
}
