import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trao_doi_do_app/core/services/permission_service.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

class PermissionNotifier extends StateNotifier<PermissionState> {
  final PermissionService _permissionService;
  final ILogger _logger;

  PermissionNotifier(this._permissionService, this._logger)
    : super(const PermissionState()) {
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    state = state.copyWith(isLoading: true);
    await checkAllPermissions();
    state = state.copyWith(isLoading: false);
  }

  Future<void> checkAllPermissions() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final cameraStatus = await _permissionService.checkPermission(
        Permission.camera,
      );
      final notificationStatus = await _permissionService.checkPermission(
        Permission.notification,
      );
      final hasPermissionsPermanentlyDenied =
          await _permissionService.hasPermissionsPermanentlyDenied();

      state = state.copyWith(
        isCameraGranted: cameraStatus.isGranted,
        isNotificationGranted: notificationStatus.isGranted,
        hasPermissionsPermanentlyDenied: hasPermissionsPermanentlyDenied,
        isLoading: false,
      );

      _logger.i(
        'Permissions checked - Camera: $cameraStatus, Notification: $notificationStatus',
      );
    } catch (e, stackTrace) {
      _logger.e('Error checking permissions', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi kiểm tra quyền: $e',
      );
    }
  }

  Future<bool> requestRequiredPermissions() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final statuses = await _permissionService.requestAllPermissions();

      final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
      final notificationGranted =
          statuses[Permission.notification]?.isGranted ?? false;
      final hasPermissionsPermanentlyDenied =
          await _permissionService.hasPermissionsPermanentlyDenied();

      state = state.copyWith(
        isCameraGranted: cameraGranted,
        isNotificationGranted: notificationGranted,
        hasPermissionsPermanentlyDenied: hasPermissionsPermanentlyDenied,
        isLoading: false,
      );

      final allGranted = cameraGranted && notificationGranted;

      if (!allGranted) {
        final deniedPermissions = <String>[];
        if (!cameraGranted) deniedPermissions.add('Camera');
        if (!notificationGranted) deniedPermissions.add('Thông báo');

        state = state.copyWith(
          error: 'Một số quyền chưa được cấp: ${deniedPermissions.join(', ')}',
        );
      }

      return allGranted;
    } catch (e, stackTrace) {
      _logger.e('Error requesting permissions', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi yêu cầu quyền: $e',
      );
      return false;
    }
  }

  Future<bool> requestCameraPermission() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final status = await _permissionService.requestCameraPermission();
      final isGranted = status.isGranted;

      state = state.copyWith(isCameraGranted: isGranted, isLoading: false);

      if (!isGranted) {
        state = state.copyWith(error: 'Quyền camera chưa được cấp');
      }

      return isGranted;
    } catch (e, stackTrace) {
      _logger.e('Error requesting camera permission', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi yêu cầu quyền camera: $e',
      );
      return false;
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final status = await _permissionService.requestNotificationPermission();
      final isGranted = status.isGranted;

      state = state.copyWith(
        isNotificationGranted: isGranted,
        isLoading: false,
      );

      if (!isGranted) {
        state = state.copyWith(error: 'Quyền thông báo chưa được cấp');
      }

      return isGranted;
    } catch (e, stackTrace) {
      _logger.e('Error requesting notification permission', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi yêu cầu quyền thông báo: $e',
      );
      return false;
    }
  }

  Future<void> openAppSettings() async {
    try {
      await _permissionService.openAppSettings();
      // Check permissions again after user returns from settings
      await Future.delayed(const Duration(milliseconds: 500));
      await checkAllPermissions();
    } catch (e, stackTrace) {
      _logger.e('Error opening app settings', e, stackTrace);
      state = state.copyWith(error: 'Không thể mở cài đặt ứng dụng');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class PermissionState {
  final bool isLoading;
  final bool isCameraGranted;
  final bool isNotificationGranted;
  final bool hasPermissionsPermanentlyDenied;
  final String? error;

  const PermissionState({
    this.isLoading = false,
    this.isCameraGranted = false,
    this.isNotificationGranted = false,
    this.hasPermissionsPermanentlyDenied = false,
    this.error,
  });

  bool get hasError => error != null;
  bool get areAllPermissionsGranted => isCameraGranted && isNotificationGranted;
  bool get hasAnyPermissionGranted => isCameraGranted || isNotificationGranted;

  PermissionState copyWith({
    bool? isLoading,
    bool? isCameraGranted,
    bool? isNotificationGranted,
    bool? hasPermissionsPermanentlyDenied,
    String? error,
  }) {
    return PermissionState(
      isLoading: isLoading ?? this.isLoading,
      isCameraGranted: isCameraGranted ?? this.isCameraGranted,
      isNotificationGranted:
          isNotificationGranted ?? this.isNotificationGranted,
      hasPermissionsPermanentlyDenied:
          hasPermissionsPermanentlyDenied ??
          this.hasPermissionsPermanentlyDenied,
      error: error,
    );
  }

  @override
  String toString() {
    return 'PermissionState(isLoading: $isLoading, camera: $isCameraGranted, notification: $isNotificationGranted, permanentlyDenied: $hasPermissionsPermanentlyDenied, error: $error)';
  }
}
