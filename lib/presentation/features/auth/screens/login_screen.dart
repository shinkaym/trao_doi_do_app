import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_text_field.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';
import 'package:trao_doi_do_app/presentation/widgets/secondary_button.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đăng Nhập',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: ext.primaryTextColor,
              ),
            ),
            const SizedBox(height: 32),

            CustomTextField(
              label: 'Email',
              hint: 'Nhập email',
              controller: emailController,
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

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

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text('Quên mật khẩu?'),
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(text: 'ĐĂNG NHẬP', onPressed: () {}),
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Text(
                    'Bạn chưa có tài khoản?',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    text: 'ĐĂNG KÝ',
                    onPressed: () => context.push('/register'),
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
