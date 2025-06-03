import 'package:flutter/material.dart';
import 'theme_extensions.dart';

extension DialogExtensions on BuildContext {
  Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => Theme(
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
            onPressed: () => Navigator.of(this).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(color: appColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(this).pop(true),
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
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Bổ sung: Info Dialog
  void showInfoDialog({
    required String title,
    required String content,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    showAppDialog(
      child: AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: appColors.primary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: appColors.primaryTextColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: textTheme.bodyMedium?.copyWith(
            color: appColors.secondaryTextColor,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(this).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Bổ sung: Error Dialog
  void showErrorDialog({
    String title = 'Lỗi',
    required String message,
    String buttonText = 'OK',
  }) {
    showAppDialog(
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: appColors.danger),
            const SizedBox(width: 8),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: appColors.danger,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(
            color: appColors.secondaryTextColor,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(this).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.danger,
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Bổ sung: Success Dialog
  void showSuccessDialog({
    String title = 'Thành công',
    required String message,
    String buttonText = 'OK',
  }) {
    showAppDialog(
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: appColors.success),
            const SizedBox(width: 8),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: appColors.success,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(
            color: appColors.secondaryTextColor,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(this).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Bổ sung: Input Dialog
  Future<String?> showInputDialog({
    required String title,
    String? hint,
    String? initialValue,
    String confirmText = 'OK',
    String cancelText = 'Hủy',
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    return showAppDialog<String>(
      child: AlertDialog(
        title: Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: appColors.primaryTextColor,
          ),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            autofocus: true,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(this).pop(),
            child: Text(
              cancelText,
              style: TextStyle(color: appColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? true) {
                Navigator.of(this).pop(controller.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    ).then((value) {
      controller.dispose();
      return value;
    });
  }

  // Bổ sung: Choice Dialog (Single Choice)
  Future<T?> showChoiceDialog<T>({
    required String title,
    required List<T> options,
    required String Function(T) itemBuilder,
    T? selectedValue,
  }) {
    return showAppDialog<T>(
      child: AlertDialog(
        title: Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: appColors.primaryTextColor,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = option == selectedValue;
              return ListTile(
                title: Text(
                  itemBuilder(option),
                  style: textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? appColors.primary 
                        : appColors.primaryTextColor,
                  ),
                ),
                leading: Radio<T>(
                  value: option,
                  groupValue: selectedValue,
                  activeColor: appColors.primary,
                  onChanged: (value) => Navigator.of(this).pop(value),
                ),
                onTap: () => Navigator.of(this).pop(option),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(this).pop(),
            child: Text(
              'Hủy',
              style: TextStyle(color: appColors.secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  // Bổ sung: Dismiss loading dialog helper
  void dismissDialog() {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }

  // Bổ sung: Progress Dialog
  void showProgressDialog({
    required String title,
    required Stream<double> progressStream,
    String? message,
  }) {
    showAppDialog(
      barrierDismissible: false,
      child: AlertDialog(
        title: Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: appColors.primaryTextColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<double>(
              stream: progressStream,
              builder: (context, snapshot) {
                final progress = snapshot.data ?? 0.0;
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: appColors.card,
                      valueColor: AlwaysStoppedAnimation(appColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: textTheme.bodySmall?.copyWith(
                        color: appColors.secondaryTextColor,
                      ),
                    ),
                  ],
                );
              },
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: appColors.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}