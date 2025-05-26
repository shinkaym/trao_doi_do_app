import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/config/theme_mode_provider.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class ThemeToggleTile extends ConsumerWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    final isDark = mode == ThemeMode.dark;

    // Determine the icon and title based on the current theme
    final icon = isDark ? Icons.light_mode : Icons.dark_mode;
    final title = isDark ? 'Chế độ sáng' : 'Chế độ tối';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
       decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: ext.card,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.hovered)) {
                // Dùng màu primary với opacity để nổi bật trên nền
                return ext.primary.withOpacity(0.7);
              }
              if (states.contains(MaterialState.selected)) {
                return ext.primary;
              }
              return ext.secondaryTextColor;
            }),
            trackColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.hovered)) {
                // Dùng primary nhạt hơn cho track khi hover
                return ext.primary.withOpacity(0.2);
              }
              if (states.contains(MaterialState.selected)) {
                return ext.accentLight.withOpacity(0.7);
              }
              return ext.accentLight.withOpacity(0.4);
            }),
          ),
        ),
        child: SwitchListTile(
          secondary: Icon(icon),
          title: Text(title),
          subtitle: Text(
            'Thay đổi giao diện sáng/tối',
            style: theme.textTheme.bodySmall?.copyWith(color: ext.secondaryTextColor),
          ),
          value: isDark,
          onChanged: (val) => notifier.toggleTheme(),
        ),
      ),
    );
  }
}
