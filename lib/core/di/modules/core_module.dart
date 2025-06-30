import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';
import 'package:trao_doi_do_app/core/services/permission_service.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';
import 'package:trao_doi_do_app/presentation/providers/permission_provider.dart';

/// Core Module - Contains fundamental dependencies
class CoreModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

/// Logger provider - Single source of truth
final loggerProvider = Provider<ILogger>((ref) => LoggerUtils());

/// Hive provider
final hiveProvider = Provider<HiveInterface>((ref) => Hive);

/// Settings box provider with caching
final settingsBoxProvider = Provider<Box>((ref) {
  final hive = ref.watch(hiveProvider);
  return hive.box(StorageKeys.settings);
});

/// Secure storage provider for sensitive data (tokens, credentials)
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
});

// =============================================================================
// PERMISSION PROVIDERS
// =============================================================================

/// Connectivity instance provider
final connectivityInstanceProvider = Provider<Connectivity>(
  (ref) => Connectivity(),
);

/// Permission service provider
final permissionServiceProvider = Provider<PermissionService>((ref) {
  final logger = ref.watch(loggerProvider);
  return PermissionService(logger);
});

/// Permission notifier provider
final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
      final permissionService = ref.watch(permissionServiceProvider);
      final logger = ref.watch(loggerProvider);
      return PermissionNotifier(permissionService, logger);
    });

// =============================================================================
// PERMISSION CHECK PROVIDERS
// =============================================================================

/// Check if all required permissions are granted
final allPermissionsGrantedProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.areAllPermissionsGranted;
});

/// Check if camera permission is granted
final cameraPermissionGrantedProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isCameraGranted;
});

/// Check if notification permission is granted
final notificationPermissionGrantedProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isNotificationGranted;
});

/// Check if any permissions are permanently denied
final hasPermissionsPermanentlyDeniedProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.hasPermissionsPermanentlyDenied;
});

// =============================================================================
// APP INITIALIZATION CHECK PROVIDERS
// =============================================================================

/// Check if app has all required permissions and connectivity
final appReadyProvider = Provider<bool>((ref) {
  final hasPermissions = ref.watch(allPermissionsGrantedProvider);

  // App is ready if it has permissions and connectivity
  // You can modify this logic based on your requirements
  return hasPermissions;
});

/// Check if app needs permission setup
final needsPermissionSetupProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return !permissionState.areAllPermissionsGranted;
});
