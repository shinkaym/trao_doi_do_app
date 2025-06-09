import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme_extensions.dart';

extension DialogExtensions on BuildContext {
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
            onPressed: () => _dismissDialog(),
            child: Text(
              cancelText,
              style: TextStyle(color: appColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => _dismissDialog(true),
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
            onPressed: () => _dismissDialog(),
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
              style: textTheme.titleLarge?.copyWith(color: appColors.danger),
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
            onPressed: () => _dismissDialog(),
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
              style: textTheme.titleLarge?.copyWith(color: appColors.success),
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
            onPressed: () => _dismissDialog(),
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
            onPressed: () => _dismissDialog(),
            child: Text(
              cancelText,
              style: TextStyle(color: appColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? true) {
                _dismissDialog(controller.text);
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
            children:
                options.map((option) {
                  final isSelected = option == selectedValue;
                  return ListTile(
                    title: Text(
                      itemBuilder(option),
                      style: textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? appColors.primary
                                : appColors.primaryTextColor,
                      ),
                    ),
                    leading: Radio<T>(
                      value: option,
                      groupValue: selectedValue,
                      activeColor: appColors.primary,
                      onChanged: (value) => _dismissDialog(value),
                    ),
                    onTap: () => _dismissDialog(option),
                  );
                }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _dismissDialog(),
            child: Text(
              'Hủy',
              style: TextStyle(color: appColors.secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

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

  // Helper methods for GoRouter compatibility
  void _dismissDialog([dynamic result]) {
    if (canPop()) {
      pop(result);
    }
  }

  void dismissDialog() {
    _dismissDialog();
  }

  // GoRouter safe navigation methods
  void goAndDismissDialog(String location) {
    _dismissDialog();
    go(location);
  }

  void pushAndDismissDialog(String location) {
    _dismissDialog();
    push(location);
  }

  // Dialog with navigation action
  Future<bool?> showConfirmDialogWithNavigation({
    required String title,
    required String content,
    required String navigationPath,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    bool isDangerous = false,
    bool useGo = true, // true for go(), false for push()
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
            onPressed: () => _dismissDialog(false),
            child: Text(
              cancelText,
              style: TextStyle(color: appColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _dismissDialog(true);
              if (useGo) {
                go(navigationPath);
              } else {
                push(navigationPath);
              }
            },
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
}
