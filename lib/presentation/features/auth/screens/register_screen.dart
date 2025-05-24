import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_text_field.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';
import 'package:trao_doi_do_app/presentation/widgets/secondary_button.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(
              'Tạo tài khoản mới',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: ext.primaryTextColor,
              ),
            ),
            const SizedBox(height: 32),

            CustomTextField(label: 'Họ và tên', hint: 'Nhập họ và tên'),
            CustomTextField(
              label: 'Số điện thoại',
              hint: 'Nhập số điện thoại',
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: 'Email',
              hint: 'Nhập email',
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: 'Mật khẩu',
              hint: 'Nhập mật khẩu',
              controller: passwordController,
              isPassword: true,
              isVisible: isPasswordVisible,
              onToggleVisibility:
                  () => setState(() => isPasswordVisible = !isPasswordVisible),
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: 'Xác nhận mật khẩu',
              hint: 'Nhập lại mật khẩu',
              controller: confirmPasswordController,
              isPassword: true,
              isVisible: isConfirmPasswordVisible,
              onToggleVisibility:
                  () => setState(
                    () => isConfirmPasswordVisible = !isConfirmPasswordVisible,
                  ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(text: 'ĐĂNG KÝ', onPressed: () {}),
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Text('Đã có tài khoản?', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    text: 'ĐĂNG NHẬP',
                    onPressed: () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
