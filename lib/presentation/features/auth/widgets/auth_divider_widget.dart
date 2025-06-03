// Tạo file: lib/widgets/auth_divider_widget.dart
import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class AuthDividerWidget extends StatelessWidget {
  final String text;

  const AuthDividerWidget({Key? key, this.text = 'hoặc'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;

    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: theme.hintColor,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.dividerColor)),
      ],
    );
  }
}

class AuthLinkWidget extends StatelessWidget {
  final String question;
  final String linkText;
  final VoidCallback onTap;

  const AuthLinkWidget({
    Key? key,
    required this.question,
    required this.linkText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(
            color: theme.hintColor,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
