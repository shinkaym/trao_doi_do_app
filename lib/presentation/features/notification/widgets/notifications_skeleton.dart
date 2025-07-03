import 'package:flutter/material.dart';

class NotificationsSkeleton extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const NotificationsSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      child: Column(
        children: List.generate(6, (index) => _buildSkeletonItem()),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 40 : 36,
            height: isTablet ? 40 : 36,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: isTablet ? 14 : 12,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Container(
                  width: double.infinity,
                  height: isTablet ? 14 : 12,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Container(
                  width: 150,
                  height: isTablet ? 14 : 12,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Container(
                  width: 100,
                  height: isTablet ? 12 : 10,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
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
