import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_layout.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Xác thực tài khoản',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Chúng tôi đã gửi mã OTP gồm 6 chữ số đến email hoặc số điện thoại của bạn.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // OTP Input
          PinCodeTextField(
            length: 6,
            appContext: context,
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 50,
              fieldWidth: 40,
              activeColor: Colors.teal,
              selectedColor: Colors.teal.shade200,
              inactiveColor: Colors.grey.shade400,
            ),
            onChanged: (value) {},
            onCompleted: (code) {
              print('OTP đã nhập: $code');
            },
          ),

          const SizedBox(height: 24),

          PrimaryButton(text: 'XÁC NHẬN', onPressed: () {}),
        ],
      ),
    );
  }
}
