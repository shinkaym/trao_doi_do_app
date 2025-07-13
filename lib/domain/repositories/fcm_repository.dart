import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';

abstract class FcmRepository {
  Future<Either<Failure, void>> saveFcmToken(String token);
  Future<Either<Failure, void>> deleteFcmToken(String token);
  Future<Either<Failure, String?>> getFcmToken();
  Future<Either<Failure, void>> clearFcmToken();
}