import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class SecurityTipsWidget extends StatelessWidget {
  const SecurityTipsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: colorScheme.primary,
                size: isTablet ? 20 : 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Mẹo tạo mật khẩu mạnh:',
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            '• Kết hợp chữ hoa, chữ thường, số và ký tự đặc biệt\n'
            '• Sử dụng cụm từ dễ nhớ nhưng khó đoán\n'
            '• Tránh sử dụng thông tin cá nhân như tên, ngày sinh',
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
