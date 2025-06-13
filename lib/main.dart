import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trao_doi_do_app/app.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/presentation/features/onboarding/providers/onboarding_provider.dart';
import 'package:trao_doi_do_app/presentation/features/splash/providers/splash_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  TimeUtils.init();

  try {
    await dotenv.load();
    await Hive.initFlutter();
    await Hive.openBox(StorageKeys.settings);

    final container = ProviderContainer();
    // Pre-load critical providers
    container.read(authProvider);
    container.read(isOnboardingCompletedProvider);
    container.read(isSplashCompletedProvider);

    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    // Error handling for initialization
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    // Fallback app without some features
    runApp(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Ứng dụng gặp lỗi khi khởi tạo',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Vui lòng thử lại sau',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
