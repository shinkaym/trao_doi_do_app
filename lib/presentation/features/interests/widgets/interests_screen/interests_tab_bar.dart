import 'package:flutter/material.dart';

class InterestsTabBar extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final TabController tabController;

  const InterestsTabBar({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: colorScheme.surface),
      child: TabBar(
        controller: tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, size: isTablet ? 20 : 18),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Đang quan tâm',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: isTablet ? 20 : 18),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Được quan tâm',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        indicatorColor: Colors.transparent,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      ),
    );
  }
}
