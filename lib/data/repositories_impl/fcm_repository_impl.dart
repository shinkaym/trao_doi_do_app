import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/local/fcm_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/fcm_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/repositories/fcm_repository.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';

class FcmRepositoryImpl implements FcmRepository {
  final FcmRemoteDataSource _remoteDataSource;
  final FcmLocalDataSource _localDataSource;

  FcmRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, void>> saveFcmToken(String token) async {
    return handleRepositoryCall<void>(() async {
      // Save to server first
      await _remoteDataSource.saveFcmToken(token);
      // Then save locally
      await _localDataSource.saveFcmToken(token);
    }, 'Lỗi lưu FCM token');
  }

  @override
  Future<Either<Failure, void>> deleteFcmToken(String token) async {
    return handleRepositoryCall<void>(() async {
      // Delete from server first
      await _remoteDataSource.deleteFcmToken(token);
      // Then clear locally
      await _localDataSource.clearFcmToken();
    }, 'Lỗi xóa FCM token');
  }

  @override
  Future<Either<Failure, String?>> getFcmToken() async {
    return handleRepositoryCall<String?>(() async {
      return await _localDataSource.getFcmToken();
    }, 'Lỗi lấy FCM token');
  }

  @override
  Future<Either<Failure, void>> clearFcmToken() async {
    return handleRepositoryCall<void>(() async {
      await _localDataSource.clearFcmToken();
    }, 'Lỗi xóa FCM token local');
  }
}
