import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/fcm_repository.dart';

class DeleteFcmTokenUseCase {
  final FcmRepository _repository;

  DeleteFcmTokenUseCase(this._repository);

  Future<Either<Failure, void>> execute(String token) async {
    return await _repository.deleteFcmToken(token);
  }
}