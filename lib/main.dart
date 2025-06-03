import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trao_doi_do_app/app.dart';
// import 'package:trao_doi_do_app/core/di/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load();

    // Setup dependency injection (Hive initialization)
    // await setupDI();

    await Hive.initFlutter();
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
