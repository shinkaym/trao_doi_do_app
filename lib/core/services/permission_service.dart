import 'package:permission_handler/permission_handler.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

class PermissionService {
  final ILogger _logger;

  PermissionService(this._logger);

  /// Check if all required permissions are granted
  Future<bool> checkAllRequiredPermissions() async {
    try {
      final permissions = await _getRequiredPermissions();

      for (final permission in permissions.entries) {
        final status = await permission.key.status;
        if (!status.isGranted) {
          _logger.w('Permission ${permission.value} is not granted: $status');
          return false;
        }
      }

      return true;
    } catch (e, stackTrace) {
      _logger.e('Error checking permissions', e, stackTrace);
      return false;
    }
  }

  /// Request all required permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    try {
      final permissions = await _getRequiredPermissions();
      final permissionList = permissions.keys.toList();

      _logger.i('Requesting permissions: ${permissions.values.join(', ')}');

      final statuses = await permissionList.request();

      // Log results
      for (final entry in statuses.entries) {
        final permissionName = permissions[entry.key] ?? 'Unknown';
        _logger.i('Permission $permissionName: ${entry.value}');
      }

      return statuses;
    } catch (e, stackTrace) {
      _logger.e('Error requesting permissions', e, stackTrace);
      return {};
    }
  }

  /// Request specific permission
  Future<PermissionStatus> requestPermission(Permission permission) async {
    try {
      _logger.i('Requesting permission: $permission');
      final status = await permission.request();
      _logger.i('Permission $permission result: $status');
      return status;
    } catch (e, stackTrace) {
      _logger.e('Error requesting permission $permission', e, stackTrace);
      return PermissionStatus.denied;
    }
  }

  /// Check specific permission status
  Future<PermissionStatus> checkPermission(Permission permission) async {
    try {
      return await permission.status;
    } catch (e, stackTrace) {
      _logger.e('Error checking permission $permission', e, stackTrace);
      return PermissionStatus.denied;
    }
  }

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await checkPermission(Permission.camera);
    return status.isGranted;
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    final status = await checkPermission(Permission.notification);
    return status.isGranted;
  }

  /// Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    return await requestPermission(Permission.camera);
  }

  /// Request notification permission
  Future<PermissionStatus> requestNotificationPermission() async {
    return await requestPermission(Permission.notification);
  }

  /// Open app settings if permission is permanently denied
  Future<bool> openAppSettings() async {
    try {
      _logger.i('Opening app settings');
      return await openAppSettings();
    } catch (e, stackTrace) {
      _logger.e('Error opening app settings', e, stackTrace);
      return false;
    }
  }

  /// Check if any permission is permanently denied
  Future<bool> hasPermissionsPermanentlyDenied() async {
    try {
      final permissions = await _getRequiredPermissions();

      for (final permission in permissions.keys) {
        final status = await permission.status;
        if (status.isPermanentlyDenied) {
          return true;
        }
      }

      return false;
    } catch (e, stackTrace) {
      _logger.e('Error checking permanently denied permissions', e, stackTrace);
      return false;
    }
  }

  /// Get list of denied permissions
  Future<List<Permission>> getDeniedPermissions() async {
    try {
      final permissions = await _getRequiredPermissions();
      final deniedPermissions = <Permission>[];

      for (final permission in permissions.keys) {
        final status = await permission.status;
        if (!status.isGranted) {
          deniedPermissions.add(permission);
        }
      }

      return deniedPermissions;
    } catch (e, stackTrace) {
      _logger.e('Error getting denied permissions', e, stackTrace);
      return [];
    }
  }

  /// Get required permissions with their display names
  Future<Map<Permission, String>> _getRequiredPermissions() async {
    return {
      Permission.camera: 'Camera',
      Permission.notification: 'Notification',
      // Add more permissions as needed
      // Permission.storage: 'Storage',
      // Permission.location: 'Location',
    };
  }

  /// Get user-friendly permission description
  String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Quyền truy cập camera để chụp ảnh sản phẩm';
      case Permission.notification:
        return 'Quyền nhận thông báo để cập nhật tin tức mới';
      case Permission.storage:
        return 'Quyền truy cập bộ nhớ để lưu trữ ảnh';
      case Permission.location:
        return 'Quyền truy cập vị trí để tìm kiếm xung quanh';
      default:
        return 'Quyền này cần thiết để ứng dụng hoạt động';
    }
  }

  /// Get permission icon
  String getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return '📷';
      case Permission.notification:
        return '🔔';
      case Permission.storage:
        return '💾';
      case Permission.location:
        return '📍';
      default:
        return '⚙️';
    }
  }
}
