import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/fcm_repository.dart';

class SaveFcmTokenUseCase {
  final FcmRepository _repository;

  SaveFcmTokenUseCase(this._repository);

  Future<Either<Failure, void>> execute(String token) async {
    return await _repository.saveFcmToken(token);
  }
}
