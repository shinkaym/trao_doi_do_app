import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class AppBarLeading extends StatelessWidget {
  final bool isSearchMode;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback onToggleSearch;
  final bool isTablet;
  final bool isDark;
  final Color appBarBgColor;
  final Color appBarFgColor;

  const AppBarLeading({
    super.key,
    required this.isSearchMode,
    required this.showBackButton,
    required this.onBackPressed,
    required this.onToggleSearch,
    required this.isTablet,
    required this.isDark,
    required this.appBarBgColor,
    required this.appBarFgColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearchMode) {
      return _buildSearchBackButton();
    }

    if (showBackButton) {
      return _buildBackButton(context);
    }

    return _buildLogo();
  }

  Widget _buildSearchBackButton() {
    return Container(
      margin: EdgeInsets.only(left: isTablet ? 12 : 8),
      child: IconButton(
        icon: Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color:
                isDark
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
        onPressed: onToggleSearch,
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: isTablet ? 12 : 8),
      child: IconButton(
        icon: Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color:
                isDark
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
        onPressed:
            onBackPressed ??
            () {
              if (context.canPop) {
                context.pop();
              } else {
                context.goNamed(RouteNames.home);
              }
            },
      ),
    );
  }

  Widget _buildLogo() {
    final double size = isTablet ? 20 : 18;

    return Container(
      margin: EdgeInsets.only(left: isTablet ? 16 : 12),
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
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
                  gradient: const LinearGradient(
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
      ),
    );
  }
}
