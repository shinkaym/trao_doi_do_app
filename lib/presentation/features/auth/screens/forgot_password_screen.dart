import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_text_field.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khôi phục mật khẩu',
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
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'GỬI YÊU CẦU',
              onPressed: () => context.push('/otp'),
            ),
          ],
        ),
      ),
    );
  }
}
