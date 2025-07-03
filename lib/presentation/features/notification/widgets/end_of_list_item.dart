import 'package:flutter/material.dart';

class EndOfListItem extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const EndOfListItem({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: isTablet ? 40 : 32,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Đã hiển thị tất cả thông báo',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
