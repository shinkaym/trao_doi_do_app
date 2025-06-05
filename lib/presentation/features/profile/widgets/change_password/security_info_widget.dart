import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class SecurityInfoWidget extends StatelessWidget {
  const SecurityInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final theme = context.theme;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.primary,
                size: isTablet ? 20 : 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Lưu ý bảo mật:',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            '• Mật khẩu mới phải khác mật khẩu hiện tại\n'
            '• Không chia sẻ mật khẩu với người khác\n'
            '• Sử dụng mật khẩu mạnh để bảo vệ tài khoản',
            style: TextStyle(
              color: theme.hintColor,
              fontSize: isTablet ? 14 : 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
