import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String title;
  final String subtitle;
  final IconData icon;
  final TextEditingController sharedSearchController;
  final VoidCallback resetFilters;

  const EmptyState({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sharedSearchController,
    required this.resetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = sharedSearchController.text.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isTablet ? 80 : 64, color: theme.hintColor),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            hasActiveFilters
                ? 'Không tìm thấy kết quả phù hợp với bộ lọc'
                : subtitle,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          // Hiển thị nút đặt lại bộ lọc nếu có bộ lọc đang áp dụng
          if (hasActiveFilters) ...[
            SizedBox(height: isTablet ? 24 : 20),
            ElevatedButton.icon(
              onPressed: resetFilters,
              icon: Icon(Icons.refresh, size: isTablet ? 20 : 18),
              label: Text(
                'Đặt lại bộ lọc',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
