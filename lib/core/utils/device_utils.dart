import 'package:device_info_plus/device_info_plus.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceUtils {
  static const _storage = FlutterSecureStorage();
  static final _uuid = Uuid();

  static Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: StorageKeys.deviceId);

    if (deviceId == null) {
      deviceId = _uuid.v4();
      await _storage.write(key: StorageKeys.deviceId, value: deviceId);
    }

    return deviceId;
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'Android',
        'model': androidInfo.model,
        'version': androidInfo.version.release,
        'brand': androidInfo.brand,
      };
    } catch (e) {
      try {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
        };
      } catch (e) {
        return {
          'platform': 'Unknown',
          'model': 'Unknown',
          'version': 'Unknown',
        };
      }
    }
  }
}
