import 'package:flutter/material.dart';

class RegistrationInfo extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(DateTime) formatDeadline;

  const RegistrationInfo({
    super.key,
    required this.item,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.formatDeadline,
  });

  @override
  Widget build(BuildContext context) {
    final registeredUsers = item['registeredUsers'];
    final maxRegistrations = item['maxRegistrations'];
    final deadline = item['registrationDeadline'];
    final progress = registeredUsers / maxRegistrations;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin đăng ký',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: isTablet ? 18 : 16,
                color: theme.hintColor,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Đã đăng ký: $registeredUsers/$maxRegistrations người',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 8 : 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 0.8 ? Colors.orange : colorScheme.primary,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: isTablet ? 18 : 16,
                color: theme.hintColor,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Hạn đăng ký: ${formatDeadline(deadline)}',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (registeredUsers >= maxRegistrations) ...[
            SizedBox(height: isTablet ? 12 : 8),
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: isTablet ? 16 : 14,
                    color: Colors.orange.shade700,
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Expanded(
                    child: Text(
                      'Đã đủ số lượng đăng ký',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
