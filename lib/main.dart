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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize provider container với observers
  final container = ProviderContainer(
    observers: kDebugMode ? [_ProviderLogger()] : [],
  );

  try {
    await _initializeApp(container);
    runApp(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
  } catch (e, stackTrace) {
    _handleCriticalError(container, e, stackTrace);
  }
}

/// Provider Observer cho debugging
class _ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('🔄 Provider Updated: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    print(
      '❌ Provider Failed: ${provider.name ?? provider.runtimeType} - $error',
    );
  }
}

/// Optimized initialization
Future<void> _initializeApp(ProviderContainer container) async {
  final logger = container.read(loggerProvider);

  // Parallel initialization cho performance
  await Future.wait([_initializeCore(), _initializeStorage()]);

  // Warm up critical providers
  await _warmUpProviders(container, logger);

  logger.i('🎉 App initialization completed');
}

Future<void> _initializeCore() async {
  TimeUtils.init();
  await dotenv.load();
}

Future<void> _initializeStorage() async {
  await Hive.initFlutter();
  await Hive.openBox(StorageKeys.settings);
}

/// Warm up providers để tránh cold start
Future<void> _warmUpProviders(
  ProviderContainer container,
  ILogger logger,
) async {
  try {
    final futures = <Future>[];

    // Load critical providers concurrently
    futures.add(Future(() => container.read(onboardingProvider)));
    futures.add(Future(() => container.read(splashProvider)));

    await Future.wait(futures, eagerError: false);
    logger.i('✅ Providers warmed up successfully');
  } catch (e, stackTrace) {
    logger.w('⚠️ Some providers failed to warm up', e, stackTrace);
  }
}

/// Handle critical errors
void _handleCriticalError(
  ProviderContainer container,
  Object error,
  StackTrace stackTrace,
) {
  try {
    final logger = container.read(loggerProvider);
    logger.e('❌ Critical app error', error, stackTrace);
  } catch (_) {
    debugPrint('❌ Critical app error: $error');
  }

  runApp(_ErrorApp(error.toString()));
}

/// Improved error app
class _ErrorApp extends StatelessWidget {
  final String errorMessage;

  const _ErrorApp(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Error',
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
                    'Vui lòng khởi động lại ứng dụng',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 32),
                    ExpansionTile(
                      title: const Text('Chi tiết lỗi'),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
