import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/config/theme_mode_provider.dart';

class ThemeToggleTile extends ConsumerWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final theme = Theme.of(context);

    final isDark = mode == ThemeMode.dark;

    // Determine the icon and title based on the current theme
    final icon = isDark ? Icons.light_mode : Icons.dark_mode;
    final title = isDark ? 'Chế độ sáng' : 'Chế độ tối';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: theme.iconTheme.color),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Thay đổi giao diện sáng/tối',
          style: theme.textTheme.bodySmall,
        ),
        value: isDark,
        onChanged: (val) => notifier.toggleTheme(),
      ),
    );
  }
}