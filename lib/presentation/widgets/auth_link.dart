import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class AuthLink extends StatelessWidget {
  final String question;
  final String linkText;
  final VoidCallback? onTap;

  const AuthLink({
    super.key,
    required this.question,
    required this.linkText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            question,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: isTablet ? 16 : 14,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              linkText,
              style: TextStyle(
                color:
                    onTap != null
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
