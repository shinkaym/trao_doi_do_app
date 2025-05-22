import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trao_doi_do_app/app.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// For Window to design
import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // For Mobile, Tablet
  // await dotenv.load();

  // For Window to design
  WidgetsFlutterBinding.ensureInitialized();

  final envPath = p.join(Directory.current.path, '.env');

  try {
    await dotenv.load(fileName: envPath);
    print("✅ Loaded .env from $envPath");
  } catch (e) {
    print("❌ Failed to load .env: $e");
  }

  await setupDI();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
