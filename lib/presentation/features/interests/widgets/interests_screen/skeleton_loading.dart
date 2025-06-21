import 'package:flutter/material.dart';

class SkeletonLoading extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const SkeletonLoading({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
          sliver: SliverList.separated(
            separatorBuilder:
                (context, index) => SizedBox(height: isTablet ? 8 : 6),
            itemCount: 5,
            itemBuilder: (context, index) {
              return SkeletonCard(
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
              );
            },
          ),
        ),
      ],
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const SkeletonCard({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              children: [
                Container(
                  width: isTablet ? 100 : 80,
                  height: isTablet ? 28 : 24,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Container(
                  width: isTablet ? 80 : 60,
                  height: isTablet ? 14 : 12,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Title skeleton
            Container(
              width: double.infinity,
              height: isTablet ? 22 : 20,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            SizedBox(height: isTablet ? 8 : 6),

            // Description skeleton
            Container(
              width: double.infinity * 0.8,
              height: isTablet ? 16 : 14,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            SizedBox(height: isTablet ? 6 : 4),

            Container(
              width: double.infinity * 0.6,
              height: isTablet ? 16 : 14,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Action buttons skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: isTablet ? 44 : 38,
                  height: isTablet ? 44 : 38,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Container(
                  width: isTablet ? 44 : 38,
                  height: isTablet ? 44 : 38,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
