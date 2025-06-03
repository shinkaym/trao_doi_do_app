import 'package:flutter/material.dart';
import 'theme_extensions.dart';

extension SnackbarExtensions on BuildContext {
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
        backgroundColor: backgroundColor ?? appColors.primary,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(
          MediaQuery.of(this).size.width > 600 ? 20.0 : 16.0,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void showSuccessSnackBar(String message) => showSnackBar(
    message,
    backgroundColor: appColors.success,
    textColor: Colors.white,
    icon: Icons.check_circle_outline,
  );

  void showErrorSnackBar(String message) => showSnackBar(
    message,
    backgroundColor: appColors.danger,
    textColor: Colors.white,
    icon: Icons.error_outline,
  );

  void showWarningSnackBar(String message) => showSnackBar(
    message,
    backgroundColor: appColors.warning,
    textColor: Colors.white,
    icon: Icons.warning_outlined,
  );

  void showInfoSnackBar(String message) => showSnackBar(
    message,
    backgroundColor: appColors.primary,
    textColor: appColors.onPrimary,
    icon: Icons.info_outline,
  );
}
