import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trao_doi_do_app/app.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/presentation/features/onboarding/providers/onboarding_provider.dart';
import 'package:trao_doi_do_app/presentation/features/splash/providers/splash_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize provider container
  final container = ProviderContainer();

  try {
    // Initialize app with proper error handling
    await _initializeApp(container);

    // Run the app
    runApp(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
  } catch (e, stackTrace) {
    // Log error if logger is available
    try {
      final logger = container.read(loggerProvider);
      logger.e('❌ Critical error during app initialization', e, stackTrace);
    } catch (_) {
      // Fallback to print if logger fails
      print('❌ Critical error during app initialization: $e');
      print('Stack trace: $stackTrace');
    }

    // Show error screen
    runApp(_buildErrorApp(e.toString()));
  }
}

/// Initialize the application with proper error handling
Future<void> _initializeApp(ProviderContainer container) async {
  final logger = container.read(loggerProvider);

  // Initialize time utilities
  TimeUtils.init();

  // Load environment variables
  await dotenv.load();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox(StorageKeys.settings);

  // Pre-load critical providers
  await _preloadProviders(container, logger);

  logger.i('🎉 App initialization completed successfully');
}

/// Pre-load critical providers to avoid cold starts
Future<void> _preloadProviders(
  ProviderContainer container,
  ILogger logger,
) async {
  try {
    // Load auth provider
    container.read(authProvider);

    // Load onboarding provider
    container.read(isOnboardingCompletedProvider);

    // Load splash provider
    container.read(isSplashCompletedProvider);
  } catch (e, stackTrace) {
    logger.w('⚠️ Some providers failed to preload', e, stackTrace);
    // Don't rethrow - app can still function
  }
}

/// Build error app when initialization fails
Widget _buildErrorApp(String errorMessage) {
  return MaterialApp(
    title: 'ShareAndSave - Error',
    theme: ThemeData(
      primarySwatch: Colors.red,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Ứng dụng gặp lỗi khi khởi tạo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vui lòng đóng ứng dụng và thử lại sau',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Show error details in debug mode
                if (kDebugMode) ...[
                  ExpansionTile(
                    title: const Text('Chi tiết lỗi'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // In a real app, you might want to restart the app
                    // or show a restart dialog
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
