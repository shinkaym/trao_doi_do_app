import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Provider cho theme mode với secure storage persistence
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
  static const String _key = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final themeIndexStr = await _secureStorage.read(key: _key);
      if (themeIndexStr != null) {
        final themeIndex = int.tryParse(themeIndexStr) ?? 0;
        if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
          state = ThemeMode.values[themeIndex];
        }
      }
    } catch (e) {
      // If there's an error reading from secure storage, use default theme
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    try {
      state = mode;
      await _secureStorage.write(key: _key, value: mode.index.toString());
    } catch (e) {
      // Handle error if needed
      debugPrint('Error saving theme mode: $e');
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;
  bool get isLightMode => state == ThemeMode.light;
  bool get isSystemMode => state == ThemeMode.system;
}
