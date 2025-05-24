import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/profile_tile.dart';
import 'package:trao_doi_do_app/presentation/widgets/theme_toggle_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Hồ sơ',
      notificationCount: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin cá nhân
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'John Doe',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text('john@example.com'),
                  Text('0901234567'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Menu options
          ProfileTile(
            icon: Icons.edit,
            title: 'Chỉnh sửa thông tin',
            subtitle: 'Tên, email, số điện thoại',
            onTap: () => context.push('/edit-profile'),
          ),
          ProfileTile(
            icon: Icons.vpn_key,
            title: 'Đổi mật khẩu',
            subtitle: 'Thay đổi mật khẩu đăng nhập',
            onTap: () => context.push('/change-password'),
          ),
          ProfileTile(
            icon: Icons.event_note,
            title: 'Yêu cầu đã gửi',
            subtitle: 'Xem lại các yêu cầu của bạn',
            onTap: () => context.push('/requests'),
          ),
          ThemeToggleTile(),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                // TODO: Handle logout
              },
            ),
          ),
        ],
      ),
    );
  }
}
