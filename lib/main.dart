import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trao_doi_do_app/app.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/config/theme_mode_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load();

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();

    // Setup dependency injection
    await setupDI();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Error handling for initialization
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    // Fallback app without some features
    runApp(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Ứng dụng gặp lỗi khi khởi tạo')),
          ),
        ),
      ),
    );
  }
}
