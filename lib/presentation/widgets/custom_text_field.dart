import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType inputType;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;
  final int minLines;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.inputType = TextInputType.text,
    this.isPassword = false,
    this.isVisible = false,
    this.onToggleVisibility,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        textAlign: TextAlign.start,
        controller: controller,
        keyboardType: TextInputType.multiline,
        obscureText: isPassword && !isVisible,
        cursorColor: ext.secondaryTextColor,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: ext.primaryTextColor),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ext.primaryTextColor),
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: onToggleVisibility,
                  )
                  : null,
        ),
      ),
    );
  }
}
