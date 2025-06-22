import 'package:flutter/material.dart';

class InterestsTabBar extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final TabController tabController;
  final int interestedPostsUnreadCount; // Unread count for "Đang quan tâm" tab
  final int postsWithInterestsUnreadCount; // Unread count for "Được quan tâm" tab

  const InterestsTabBar({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.tabController,
    this.interestedPostsUnreadCount = 0,
    this.postsWithInterestsUnreadCount = 0,
  });

  Widget _buildBadge(int count) {
    if (count <= 0) return const SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.only(left: isTablet ? 6 : 4),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 6 : 4,
        vertical: isTablet ? 2 : 1,
      ),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
      ),
      constraints: BoxConstraints(
        minWidth: isTablet ? 18 : 16,
        minHeight: isTablet ? 18 : 16,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 11 : 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

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
                _buildBadge(interestedPostsUnreadCount),
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
                _buildBadge(postsWithInterestsUnreadCount),
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