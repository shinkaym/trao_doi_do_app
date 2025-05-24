import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_layout.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_text_field.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return AuthLayout(
      title: 'Khôi phục mật khẩu',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }
}
