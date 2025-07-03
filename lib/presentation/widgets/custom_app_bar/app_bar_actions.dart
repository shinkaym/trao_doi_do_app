import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class AppBarActions {
  final bool showSearchButton;
  final bool showNotificationButton;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback onToggleSearch;
  final List<Widget>? additionalActions;
  final bool isTablet;
  final bool isDark;
  final Color foregroundColor;

  const AppBarActions({
    required this.showSearchButton,
    required this.showNotificationButton,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onToggleSearch,
    required this.additionalActions,
    required this.isTablet,
    required this.isDark,
    required this.foregroundColor,
  });

  List<Widget> build(BuildContext context) {
    final actions = <Widget>[];

    if (showSearchButton) {
      actions.add(_buildSearchButton());
    }

    if (showNotificationButton) {
      actions.add(_buildNotificationButton(context));
    }

    if (additionalActions != null) {
      actions.addAll(additionalActions!);
    }

    actions.add(_buildMoreOptionsMenu(context));

    return actions;
  }

  Widget _buildSearchButton() {
    return Container(
      margin: EdgeInsets.only(right: isTablet ? 8 : 4),
      child: IconButton(
        icon: Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.search_rounded,
            color: foregroundColor.withOpacity(0.8),
            size: isTablet ? 22 : 20,
          ),
        ),
        onPressed: onToggleSearch,
        tooltip: 'Tìm kiếm',
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: isTablet ? 8 : 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: foregroundColor.withOpacity(0.8),
                size: isTablet ? 22 : 20,
              ),
            ),
            onPressed:
                onNotificationTap ??
                () => context.pushNamed(RouteNames.notifications),
            tooltip: 'Thông báo',
          ),
          if (notificationCount > 0)
            Positioned(
              right: isTablet ? 10 : 8,
              top: isTablet ? 10 : 8,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 8 : 6,
                  vertical: isTablet ? 4 : 3,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4757), Color(0xFFFF6B7A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4757).withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: BoxConstraints(
                  minWidth: isTablet ? 24 : 20,
                  minHeight: isTablet ? 20 : 16,
                ),
                child: Text(
                  notificationCount > 99 ? '99+' : notificationCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 11 : 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMoreOptionsMenu(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: isTablet ? 16 : 12),
      child: PopupMenuButton<String>(
        offset: Offset(0, isTablet ? 60 : 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        elevation: 8,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.more_vert_rounded,
            color: foregroundColor.withOpacity(0.8),
            size: isTablet ? 22 : 20,
          ),
        ),
        itemBuilder:
            (BuildContext context) => [
              PopupMenuItem<String>(
                value: RouteNames.help,
                height: isTablet ? 50 : 44,
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      color: foregroundColor.withOpacity(0.7),
                      size: isTablet ? 22 : 20,
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Text(
                      'Trợ giúp',
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
        onSelected: (String value) {
          context.pushNamed(value);
        },
      ),
    );
  }
}
