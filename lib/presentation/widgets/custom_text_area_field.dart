import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class CustomTextAreaField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final bool readOnly;

  const CustomTextAreaField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.minLines = 4,
    this.maxLines = 8,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: TextInputType.multiline,
            minLines: minLines,
            maxLines: maxLines,
            cursorColor: ext.secondary,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ext.primaryTextColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
