import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
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

  Future<bool> isAccessTokenExpired();
  Future<bool> isRefreshTokenExpired();
  Future<bool> shouldRefreshAccessToken();
  Future<void> saveTokensWithTimestamp(String accessToken, String refreshToken);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<String?> getAccessToken() async {
    // Check if token is expired before returning
    if (await isAccessTokenExpired()) {
      return null;
    }
    return await _storage.read(key: StorageKeys.accessToken);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
    await _storage.write(
      key: StorageKeys.accessTokenTimestamp,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<String?> getRefreshToken() async {
    // Check if refresh token is expired before returning
    if (await isRefreshTokenExpired()) {
      await clearTokens(); // Clear all tokens if refresh token is expired
      return null;
    }
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
    await _storage.write(
      key: StorageKeys.refreshTokenTimestamp,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.accessTokenTimestamp);
    await _storage.delete(key: StorageKeys.refreshTokenTimestamp);
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

  @override
  Future<bool> isAccessTokenExpired() async {
    final timestampStr = await _storage.read(
      key: StorageKeys.accessTokenTimestamp,
    );
    if (timestampStr == null) return true;

    try {
      final timestamp = int.parse(timestampStr);
      final tokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final expiryTime = tokenTime.add(
        Duration(milliseconds: ApiConstants.accessTokenExpiryMs),
      );
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      return true; // If we can't parse timestamp, consider token expired
    }
  }

  @override
  Future<bool> isRefreshTokenExpired() async {
    final timestampStr = await _storage.read(
      key: StorageKeys.refreshTokenTimestamp,
    );
    if (timestampStr == null) return true;

    try {
      final timestamp = int.parse(timestampStr);
      final tokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final expiryTime = tokenTime.add(
        Duration(milliseconds: ApiConstants.refreshTokenExpiryMs),
      );
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      return true; // If we can't parse timestamp, consider token expired
    }
  }

  @override
  Future<bool> shouldRefreshAccessToken() async {
    final timestampStr = await _storage.read(
      key: StorageKeys.accessTokenTimestamp,
    );
    if (timestampStr == null) return true;

    try {
      final timestamp = int.parse(timestampStr);
      final tokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final refreshTime = tokenTime.add(
        Duration(
          milliseconds:
              ApiConstants.accessTokenExpiryMs -
              ApiConstants.tokenRefreshBufferMs,
        ),
      );
      return DateTime.now().isAfter(refreshTime);
    } catch (e) {
      return true;
    }
  }

  @override
  Future<void> saveTokensWithTimestamp(
    String accessToken,
    String refreshToken,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();

    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    await _storage.write(key: StorageKeys.accessTokenTimestamp, value: now);
    await _storage.write(key: StorageKeys.refreshTokenTimestamp, value: now);
  }
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(const FlutterSecureStorage());
});
