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
    final isDark = context.isDarkMode;

    // Facebook-inspired colors
    final appBarBgColor =
        backgroundColor ?? (isDark ? const Color(0xFF1B1B1B) : Colors.white);
    final appBarFgColor =
        foregroundColor ?? (isDark ? Colors.white : const Color(0xFF1C1E21));
    final toolbarHeight = isTablet ? 70.0 : 60.0;

    // Tạo SystemUiOverlayStyle một lần duy nhất
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: AppBar(
        // Sử dụng màu trực tiếp thay vì transparent
        backgroundColor: appBarBgColor,
        foregroundColor: appBarFgColor,
        elevation: 0, // Tắt shadow mặc định
        toolbarHeight: toolbarHeight,
        // Loại bỏ systemOverlayStyle để tránh conflict
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: appBarBgColor,
            // Chỉ thêm shadow nếu cần thiết
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        bottom: bottom != null
            ? PreferredSize(
                preferredSize: bottom!.preferredSize,
                child: Container(
                  decoration: BoxDecoration(
                    color: appBarBgColor,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.grey.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: bottom!,
                ),
              )
            : null,
        leading: showBackButton
            ? Container(
                margin: EdgeInsets.only(left: isTablet ? 12 : 8),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(isTablet ? 10 : 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: appBarFgColor,
                      size: isTablet ? 20 : 18,
                    ),
                  ),
                  onPressed: onBackPressed ??
                      () {
                        if (context.canPop) {
                          context.pop();
                        } else {
                          context.goNamed('posts');
                        }
                      },
                ),
              )
            : Container(
                margin: EdgeInsets.only(left: isTablet ? 16 : 12),
                child: _buildLogo(context, isTablet),
              ),
        title: null,
        actions: _buildActions(context, appBarFgColor, isTablet, isDark),
        titleSpacing: showBackButton ? 0 : (isTablet ? 20 : 16),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, bool isTablet) {
    // Cố định kích thước logo nhỏ hơn - loại bỏ FittedBox
    final double size = isTablet ? 20 : 18; // Kích thước nhỏ hơn nữa

    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4), // Bo góc nhỏ hơn
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1877F2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: Colors.white,
                size: size * 0.5,
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    Color foregroundColor,
    bool isTablet,
    bool isDark,
  ) {
    final actions = <Widget>[];

    // Notification Button
    if (showNotificationButton) {
      actions.add(
        Container(
          margin: EdgeInsets.only(right: isTablet ? 8 : 4),
          child: _buildNotificationButton(
            context,
            foregroundColor,
            isTablet,
            isDark,
          ),
        ),
      );
    }

    // Additional Actions
    if (additionalActions != null) {
      actions.addAll(additionalActions!);
    }

    // More Options Menu (thay thế Menu Button)
    actions.add(
      Container(
        margin: EdgeInsets.only(right: isTablet ? 16 : 12),
        child: _buildMoreOptionsMenu(
          context,
          foregroundColor,
          isTablet,
          isDark,
        ),
      ),
    );

    return actions;
  }

  Widget _buildMoreOptionsMenu(
    BuildContext context,
    Color foregroundColor,
    bool isTablet,
    bool isDark,
  ) {
    return PopupMenuButton<String>(
      offset: Offset(0, isTablet ? 60 : 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      elevation: 8,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 10 : 8),
        decoration: BoxDecoration(
          color: isDark
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
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'about',
          height: isTablet ? 50 : 44,
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: foregroundColor.withOpacity(0.7),
                size: isTablet ? 22 : 20,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Giới thiệu',
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'help',
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
        switch (value) {
          case 'about':
            context.pushNamed('about'); // Chuyển đến trang giới thiệu
            break;
          case 'help':
            context.pushNamed('help'); // Chuyển đến trang trợ giúp
            break;
        }
      },
    );
  }

  Widget _buildNotificationButton(
    BuildContext context,
    Color foregroundColor,
    bool isTablet,
    bool isDark,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(isTablet ? 10 : 8),
            decoration: BoxDecoration(
              color: isDark
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
              onNotificationTap ?? () => context.pushNamed('notifications'),
          tooltip: 'Thông báo',
        ),

        // Modern Notification Badge
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
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF4757), // Modern Red
                    const Color(0xFFFF6B7A), // Lighter Red
                  ],
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
    );
  }

  @override
  Size get preferredSize {
    final isTablet = WidgetsBinding
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