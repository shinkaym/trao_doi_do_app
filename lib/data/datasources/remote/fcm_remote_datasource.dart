import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';

abstract class FcmRemoteDataSource {
  Future<void> saveFcmToken(String token);
  Future<void> deleteFcmToken(String token);
}

class FcmRemoteDataSourceImpl implements FcmRemoteDataSource {
  final DioClient _dioClient;

  FcmRemoteDataSourceImpl(this._dioClient);

  @override
  Future<void> saveFcmToken(String token) async {
    await _dioClient.post(
      '${ApiConstants.notifications}/fcm-token',
      data: {'token': token},
    );
  }

  @override
  Future<void> deleteFcmToken(String token) async {
    await _dioClient.delete(
      '${ApiConstants.notifications}/fcm-token',
      data: {'token': token},
    );
  }
}
