import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider cho SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

// Provider cho theme mode với persistence
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.read(sharedPreferencesProvider)),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const String _key = 'theme_mode';

  ThemeModeNotifier(this._prefs) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeIndex = _prefs.getInt(_key) ?? 0;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setInt(_key, mode.index);
  }
}
