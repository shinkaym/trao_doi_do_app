import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotificationButton;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<Widget>? additionalActions;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotificationButton = true,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.additionalActions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    final appBarBgColor = backgroundColor ?? colorScheme.primary;
    final appBarFgColor = foregroundColor ?? Colors.white;
    final toolbarHeight = isTablet ? 70.0 : 60.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: appBarBgColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: AppBar(
        backgroundColor: appBarBgColor,
        foregroundColor: appBarFgColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        toolbarHeight: toolbarHeight,
        bottom:
            bottom != null
                ? PreferredSize(
                  preferredSize: bottom!.preferredSize,
                  child: Container(
                    decoration: BoxDecoration(
                      color: appBarBgColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: bottom!,
                  ),
                )
                : null,
        leading:
            showBackButton
                ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: appBarFgColor,
                    size: isTablet ? 26 : 24,
                  ),
                  onPressed:
                      onBackPressed ??
                      () {
                        if (context.canPop) {
                          context.pop();
                        } else {
                          context.goNamed('posts');
                        }
                      },
                )
                : null,
        title: Row(
          children: [
            // Logo
            Container(
              width: isTablet ? 40 : 32,
              height: isTablet ? 40 : 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: isTablet ? 40 : 32,
                  height: isTablet ? 40 : 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon nếu logo không tìm thấy
                    return Icon(
                      Icons.apps,
                      color: appBarFgColor,
                      size: isTablet ? 24 : 20,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: appBarFgColor,
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Notification button
          if (showNotificationButton)
            _buildNotificationButton(context, appBarFgColor, isTablet),

          // Additional actions
          if (additionalActions != null) ...additionalActions!,

          SizedBox(width: isTablet ? 16 : 12),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
    );
  }

  Widget _buildNotificationButton(
    BuildContext context,
    Color foregroundColor,
    bool isTablet,
  ) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: foregroundColor,
            size: isTablet ? 28 : 24,
          ),
          onPressed:
              onNotificationTap ?? () => context.pushNamed('notifications'),
          tooltip: 'Thông báo',
        ),

        // Notification badge
        if (notificationCount > 0)
          Positioned(
            right: isTablet ? 8 : 6,
            top: isTablet ? 8 : 6,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 6 : 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: BoxConstraints(
                minWidth: isTablet ? 20 : 16,
                minHeight: isTablet ? 20 : 16,
              ),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 11 : 9,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize {
    final isTablet =
        WidgetsBinding
                .instance
                .platformDispatcher
                .views
                .first
                .physicalSize
                .width /
            WidgetsBinding
                .instance
                .platformDispatcher
                .views
                .first
                .devicePixelRatio >
        600;
    final toolbarHeight = isTablet ? 70.0 : 60.0;
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;

    return Size.fromHeight(toolbarHeight + bottomHeight);
  }
}
