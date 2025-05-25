import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';
import 'package:trao_doi_do_app/presentation/widgets/secondary_button.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/theme_toggle_tile.dart';

class LoggedOutProfile extends StatelessWidget {
  const LoggedOutProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: 16),
        const Text(
          'Bạn chưa đăng nhập',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text('Vui lòng đăng nhập để xem thông tin hồ sơ.'),
        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Đăng nhập',
          onPressed: () => context.push('/login'),
        ),
        const SizedBox(height: 24),
        const ThemeToggleTile(),
      ],
    );
  }
}
