import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

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
