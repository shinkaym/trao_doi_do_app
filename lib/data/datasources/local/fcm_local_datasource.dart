import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';

abstract class FcmLocalDataSource {
  Future<String?> getFcmToken();
  Future<void> saveFcmToken(String token);
  Future<void> clearFcmToken();
}

class FcmLocalDataSourceImpl implements FcmLocalDataSource {
  final FlutterSecureStorage _storage;

  FcmLocalDataSourceImpl(this._storage);

  @override
  Future<String?> getFcmToken() async {
    return await _storage.read(key: StorageKeys.fcmToken);
  }

  @override
  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: StorageKeys.fcmToken, value: token);
  }

  @override
  Future<void> clearFcmToken() async {
    await _storage.delete(key: StorageKeys.fcmToken);
  }
}