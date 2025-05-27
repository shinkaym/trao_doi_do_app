import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_text_field.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: ext.secondary, // Set the color of the back button
        ),
        title: Text('Đổi mật khẩu', style: theme.textTheme.titleLarge),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lưu ý:'),
                  SizedBox(height: 8),
                  Text('• Mật khẩu phải có ít nhất 8 ký tự'),
                  Text('• Nên bao gồm chữ hoa, chữ thường và số'),
                  Text('• Không nên sử dụng mật khẩu đã dùng trước đây'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            CustomTextField(
              label: 'Mật khẩu hiện tại',
              controller: currentPasswordController,
              isPassword: true,
              isVisible: isCurrentPasswordVisible,
              onToggleVisibility:
                  () => setState(
                    () => isCurrentPasswordVisible = !isCurrentPasswordVisible,
                  ),
            ),

            CustomTextField(
              label: 'Mật khẩu mới',
              controller: newPasswordController,
              isPassword: true,
              isVisible: isNewPasswordVisible,
              onToggleVisibility:
                  () => setState(
                    () => isNewPasswordVisible = !isNewPasswordVisible,
                  ),
            ),

            CustomTextField(
              label: 'Xác nhận mật khẩu mới',
              controller: confirmPasswordController,
              isPassword: true,
              isVisible: isConfirmPasswordVisible,
              onToggleVisibility:
                  () => setState(
                    () => isConfirmPasswordVisible = !isConfirmPasswordVisible,
                  ),
            ),

            const SizedBox(height: 12),
            PrimaryButton(text: 'Đổi mật khẩu', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
