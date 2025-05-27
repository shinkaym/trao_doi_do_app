import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class LabeledSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool labelOnLeft;

  const LabeledSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.labelOnLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    final switchWidget = SwitchTheme(
      data: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.hovered)) {
            return ext.primary.withOpacity(0.9); // Nổi bật khi hover
          }
          if (states.contains(MaterialState.selected)) {
            return ext.primary; // Thumb rõ ràng khi bật
          }
          return ext.secondaryTextColor; // Thumb trung tính khi tắt
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.hovered)) {
            return ext.accentLight.withOpacity(0.6); // Track nhấn nhẹ khi hover
          }
          if (states.contains(MaterialState.selected)) {
            return ext.accentLight.withOpacity(0.9); // Track sáng khi bật
          }
          return ext.secondaryTextColor.withOpacity(0.3); // Track mờ khi tắt
        }),
      ),

      child: Switch(value: value, onChanged: onChanged),
    );

    final text = Text(label, style: TextStyle(color: ext.primaryTextColor, fontSize: 16.0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        spacing: 3.0,
        children: labelOnLeft ? [text, switchWidget] : [switchWidget, text],
      ),
    );
  }
}
