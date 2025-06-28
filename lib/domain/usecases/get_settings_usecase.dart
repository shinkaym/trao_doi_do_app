import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/settings_response.dart';
import 'package:trao_doi_do_app/domain/repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  Future<Either<Failure, SettingsResponse>> call() async {
    return await _repository.getSettings();
  }
}
