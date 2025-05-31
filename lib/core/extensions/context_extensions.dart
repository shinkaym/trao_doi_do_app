import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/extensions/app_theme_extension.dart';

extension ContextExtensions on BuildContext {
  // Navigation helpers
  void pushNamed(
    String name, {
    Object? extra,
    Map<String, String>? pathParameters,
  }) {
    GoRouter.of(
      this,
    ).pushNamed(name, extra: extra, pathParameters: pathParameters ?? {});
  }

  void goNamed(
    String name, {
    Object? extra,
    Map<String, String>? pathParameters,
  }) {
    GoRouter.of(
      this,
    ).goNamed(name, extra: extra, pathParameters: pathParameters ?? {});
  }

  void pop([Object? result]) {
    GoRouter.of(this).pop(result);
  }

  void pushReplacement(String location, {Object? extra}) {
    GoRouter.of(this).pushReplacement(location, extra: extra);
  }

  void go(String location, {Object? extra}) {
    GoRouter.of(this).go(location, extra: extra);
  }

  // Theme helpers - sử dụng AppThemeExtension
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Thêm getter cho AppThemeExtension
  AppThemeExtension get appColors => theme.extension<AppThemeExtension>()!;

  // MediaQuery helpers
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isTablet => screenWidth > 600;
  bool get isMobile => screenWidth <= 600;
  bool get isLargeScreen => screenWidth > 1024;

  // Responsive helpers
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get statusBarHeight => viewPadding.top;
  double get bottomPadding => viewPadding.bottom;

  // Responsive spacing helpers
  double get responsiveSpacing => isTablet ? 24.0 : 16.0;
  double get responsivePadding => isTablet ? 20.0 : 16.0;
  EdgeInsets get responsiveHorizontalPadding =>
      EdgeInsets.symmetric(horizontal: responsivePadding);
  EdgeInsets get responsiveAllPadding => EdgeInsets.all(responsivePadding);

  // SnackBar helpers - sử dụng custom colors
  void showSnackBar(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? appColors.onPrimary, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor ?? appColors.onPrimary),
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: backgroundColor ?? appColors.primary,
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(responsivePadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: appColors.danger,
      textColor: Colors.white,
      icon: Icons.error_outline,
    );
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: appColors.success,
      textColor: Colors.white,
      icon: Icons.check_circle_outline,
    );
  }

  void showWarningSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: appColors.warning,
      textColor: Colors.white,
      icon: Icons.warning_outlined,
    );
  }

  void showInfoSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: appColors.primary,
      textColor: appColors.onPrimary,
      icon: Icons.info_outline,
    );
  }

  // Dialog helpers với custom styling
  Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder:
          (context) => Theme(
            data: theme.copyWith(
              dialogTheme: DialogTheme(
                backgroundColor: appColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            child: child,
          ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    bool isDangerous = false,
  }) {
    return showAppDialog<bool>(
      child: AlertDialog(
        title: Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: appColors.primaryTextColor,
          ),
        ),
        content: Text(
          content,
          style: textTheme.bodyMedium?.copyWith(
            color: appColors.secondaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => pop(false),
            child: Text(
              cancelText,
              style: TextStyle(color: appColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDangerous ? appColors.danger : appColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Loading dialog
  void showLoadingDialog({String? message}) {
    showAppDialog(
      barrierDismissible: false,
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: appColors.primary),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: appColors.secondaryTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Bottom sheet helper với custom styling
  Future<T?> showAppBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      constraints:
          maxHeight != null ? BoxConstraints(maxHeight: maxHeight) : null,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: appColors.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: appColors.secondaryTextColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(child: child),
              ],
            ),
          ),
    );
  }

  // Focus helpers
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }

  // Utility helpers
  void hideKeyboard() => unfocus();

  // Safe area helpers
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  double get safeAreaTop => safeAreaPadding.top;
  double get safeAreaBottom => safeAreaPadding.bottom;
}
