import 'package:flutter/material.dart';

class InterestsTabBar extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final TabController tabController;
  final int interestedPostsUnreadCount;
  final int postsWithInterestsUnreadCount;

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
      margin: EdgeInsets.only(left: isTablet ? 8 : 6),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 6,
        vertical: isTablet ? 4 : 3,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(
        minWidth: isTablet ? 20 : 18,
        minHeight: isTablet ? 20 : 18,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 11 : 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTabContent({
    required IconData icon,
    required String label,
    required int badgeCount,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: isSelected 
          ? colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        border: Border.all(
          color: isSelected 
            ? colorScheme.primary.withOpacity(0.3)
            : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isTablet ? 6 : 5),
            decoration: BoxDecoration(
              color: isSelected 
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
            ),
            child: Icon(
              icon,
              size: isTablet ? 16 : 14,
              color: isSelected 
                ? Colors.white
                : colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(width: isTablet ? 8 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected 
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.8),
              letterSpacing: 0.2,
            ),
          ),
          _buildBadge(badgeCount),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: isTablet ? 12 : 8,
          ),
          child: TabBar(
            controller: tabController,
            indicator: const BoxDecoration(),
            dividerColor: Colors.transparent,
            labelPadding: EdgeInsets.zero,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
            tabs: [
              AnimatedBuilder(
                animation: tabController,
                builder: (context, child) {
                  final isSelected = tabController.index == 0;
                  return _buildTabContent(
                    icon: Icons.favorite_rounded,
                    label: 'Đang quan tâm',
                    badgeCount: interestedPostsUnreadCount,
                    isSelected: isSelected,
                  );
                },
              ),
              AnimatedBuilder(
                animation: tabController,
                builder: (context, child) {
                  final isSelected = tabController.index == 1;
                  return _buildTabContent(
                    icon: Icons.people_rounded,
                    label: 'Được quan tâm',
                    badgeCount: postsWithInterestsUnreadCount,
                    isSelected: isSelected,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}