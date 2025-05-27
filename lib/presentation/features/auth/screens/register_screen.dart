import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_layout.dart';
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

    return AuthLayout(
      title: 'Đăng ký tài khoản',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Họ và tên', 
            controller: fullNameController,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Số điện thoại',
            controller: phoneController,
            inputType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Email',
            controller: emailController,
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Mật khẩu',
            controller: passwordController,
            isPassword: true,
            isVisible: isPasswordVisible,
            onToggleVisibility:
                () => setState(() => isPasswordVisible = !isPasswordVisible),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Xác nhận mật khẩu',
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
                  textColor: ext.primaryTextColor,
                  text: 'ĐĂNG NHẬP',
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}