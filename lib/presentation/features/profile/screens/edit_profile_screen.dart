import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_text_field.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class EditProfileScreen extends StatelessWidget {
  final nameController = TextEditingController(text: 'John Doe');
  final emailController = TextEditingController(text: 'john@example.com');
  final phoneController = TextEditingController(text: '0901234567');

  EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(
        // font titleLarge
        leading: BackButton(color: ext.secondary),
        title: Text('Chỉnh sửa thông tin', style: theme.textTheme.titleLarge),

        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: ext.secondary, radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(ext.secondary),
              ),
              child: const Text('Thay đổi ảnh'),
            ),
            const SizedBox(height: 24),

            CustomTextField(
              label: 'Họ và tên',
              hint: 'Nhập họ và tên',
              controller: nameController,
            ),
            CustomTextField(
              label: 'Email',
              hint: 'Nhập email',
              inputType: TextInputType.emailAddress,
              controller: emailController,
            ),
            CustomTextField(
              label: 'Số điện thoại',
              hint: 'Nhập số điện thoại',
              inputType: TextInputType.phone,
              controller: phoneController,
            ),

            const SizedBox(height: 12),
            PrimaryButton(text: 'Lưu thay đổi', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
