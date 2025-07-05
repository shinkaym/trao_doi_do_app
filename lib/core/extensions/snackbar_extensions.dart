import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'theme_extensions.dart';

extension SnackbarExtensions on BuildContext {
  // Debouncer instance dùng chung cho tất cả snackbar
  static final _debouncer = Debouncer();

  /// Hiển thị snackbar với đầy đủ tùy chọn
  void showSnackBar(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    IconData? icon,
    bool debounce = true,
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) {
    showSnack() {
      if (!mounted) return; // Kiểm tra widget còn tồn tại

      ScaffoldMessenger.of(
        this,
      ).clearSnackBars(); // Xóa snackbar cũ trước khi hiển thị mới

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

    if (debounce) {
      _debouncer.debounce(duration: debounceDuration, onDebounce: showSnack);
    } else {
      showSnack();
    }
  }

  /// Hiển thị snackbar thành công (màu xanh)
  void showSuccessSnackBar(
    String message, {
    bool debounce = true,
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) => showSnackBar(
    message,
    backgroundColor: appColors.success,
    textColor: Colors.white,
    icon: Icons.check_circle_outline,
    debounce: debounce,
    debounceDuration: debounceDuration,
  );

  /// Hiển thị snackbar lỗi (màu đỏ)
  void showErrorSnackBar(
    String message, {
    bool debounce = true,
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) => showSnackBar(
    message,
    backgroundColor: appColors.danger,
    textColor: Colors.white,
    icon: Icons.error_outline,
    debounce: debounce,
    debounceDuration: debounceDuration,
  );

  /// Hiển thị snackbar cảnh báo (màu vàng)
  void showWarningSnackBar(
    String message, {
    bool debounce = true,
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) => showSnackBar(
    message,
    backgroundColor: appColors.warning,
    textColor: Colors.white,
    icon: Icons.warning_amber_outlined,
    debounce: debounce,
    debounceDuration: debounceDuration,
  );

  /// Hiển thị snackbar thông tin (màu xanh dương)
  void showInfoSnackBar(
    String message, {
    bool debounce = true,
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) => showSnackBar(
    message,
    backgroundColor: appColors.primary,
    textColor: Colors.white,
    icon: Icons.info_outline,
    debounce: debounce,
    debounceDuration: debounceDuration,
  );
}
