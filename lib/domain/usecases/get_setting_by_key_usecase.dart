import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/settings_response.dart';
import 'package:trao_doi_do_app/domain/repositories/settings_repository.dart';

class GetSettingByKeyUseCase {
  final SettingsRepository _repository;

  GetSettingByKeyUseCase(this._repository);

  Future<Either<Failure, SettingResponse>> call(String settingKey) async {
    return await _repository.getSettingByKey(settingKey);
  }
}
