import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';

abstract class AuthLocalDataSource {
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveRefreshToken(String token);
  Future<void> clearTokens();
  Future<String?> getUserInfo();
  Future<void> saveUserInfo(String userJson);
  Future<void> clearUserInfo();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  @override
  Future<String?> getUserInfo() async {
    return await _storage.read(key: StorageKeys.userInfo);
  }

  @override
  Future<void> saveUserInfo(String userJson) async {
    await _storage.write(key: StorageKeys.userInfo, value: userJson);
  }

  @override
  Future<void> clearUserInfo() async {
    await _storage.delete(key: StorageKeys.userInfo);
  }
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(const FlutterSecureStorage());
});