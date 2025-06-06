import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, this.text = 'hoặc'});

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
