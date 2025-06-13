import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

// Example usage trong widget:
class MyWidget extends HookConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Example'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeModeNotifier.toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current theme: ${themeMode.name}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => themeModeNotifier.setTheme(ThemeMode.light),
              child: const Text('Light Theme'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => themeModeNotifier.setTheme(ThemeMode.dark),
              child: const Text('Dark Theme'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => themeModeNotifier.setTheme(ThemeMode.system),
              child: const Text('System Theme'),
            ),
          ],
        ),
      ),
    );
  }
}
