import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class CustomSelect extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  const CustomSelect({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isTablet = context.isTablet;

    return DropdownButtonFormField<String>(
      value: value?.isEmpty == true ? null : value,
      items:
          items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.hintColor.withOpacity(enabled ? 0.7 : 0.5),
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          color: theme.hintColor.withOpacity(enabled ? 1.0 : 0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color:
              enabled
                  ? theme.colorScheme.primary
                  : theme.hintColor.withOpacity(0.5),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            icon,
            color: theme.hintColor.withOpacity(enabled ? 1.0 : 0.5),
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,
          minHeight: 50,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.dividerColor.withOpacity(0.6),
            width: 1,
          ),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.5),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
        ),
        errorStyle: TextStyle(
          color: theme.colorScheme.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      dropdownColor: theme.colorScheme.surface,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: theme.hintColor.withOpacity(enabled ? 1.0 : 0.5),
      ),
      isExpanded: true,
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
    );
  }
}
