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
}
