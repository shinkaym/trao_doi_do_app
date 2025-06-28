import 'package:flutter/material.dart';

class EndOfListItem extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;

  const EndOfListItem({super.key, required this.isTablet, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: isTablet ? 48 : 40,
            color: theme.hintColor.withOpacity(0.5),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Đã hiển thị tất cả người dùng',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
