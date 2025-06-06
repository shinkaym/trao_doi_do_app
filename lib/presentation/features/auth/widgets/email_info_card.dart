import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class EmailInfoCard extends StatelessWidget {
  final String email;

  const EmailInfoCard({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primaryContainer.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.email_outlined,
            color: colorScheme.primary,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mã OTP đã được gửi đến:',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
