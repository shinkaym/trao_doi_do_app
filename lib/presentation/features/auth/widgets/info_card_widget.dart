import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class InfoCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color? backgroundColor;
  final Color? borderColor;

  const InfoCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? colorScheme.primaryContainer.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary, size: isTablet ? 24 : 20),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.trim().isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                if (title.trim().isNotEmpty) SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: isTablet ? 16 : 14,
                    height: 1.5,
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

// Widget riêng cho thông tin email OTP
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
