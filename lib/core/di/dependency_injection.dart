// lib/core/di/dependency_injection.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

// =============================================================================
// CORE DEPENDENCIES
// =============================================================================

/// Logger provider - Single source of truth for logging
final loggerProvider = Provider<ILogger>((ref) {
  return LoggerUtils();
});

// =============================================================================
// STORAGE DEPENDENCIES
// =============================================================================

/// Hive provider for local storage
final hiveProvider = Provider<HiveInterface>((ref) {
  return Hive;
});

/// Settings box provider
final settingsBoxProvider = Provider<Box>((ref) {
  final hive = ref.watch(hiveProvider);
  return hive.box(StorageKeys.settings);
});

/// Dispose all providers when app is closing
void disposeDependencies(ProviderContainer container) {
  // Dispose resources if needed
  container.dispose();
}
