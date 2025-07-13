import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/fcm_repository.dart';

class GetFcmTokenUseCase {
  final FcmRepository _repository;

  GetFcmTokenUseCase(this._repository);

  Future<Either<Failure, String?>> execute() async {
    return await _repository.getFcmToken();
  }
}
