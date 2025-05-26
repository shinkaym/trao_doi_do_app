import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/profile_tile.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/theme_toggle_tile.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class LoggedInProfile extends StatelessWidget {
  const LoggedInProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 30,backgroundColor:ext.secondary, child: Icon(Icons.person, size: 32),),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 4),
                Text('john@example.com'),
                Text('0901234567'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        ProfileTile(
          icon: Icons.edit,
          title: 'Chỉnh sửa thông tin',
          subtitle: 'Tên, email, số điện thoại',
          onTap: () => context.push('/edit-profile'),
          color: ext.card,
        ),
        ProfileTile(
          icon: Icons.vpn_key,
          title: 'Đổi mật khẩu',
          subtitle: 'Thay đổi mật khẩu đăng nhập',
          onTap: () => context.push('/change-password'),
           color: ext.card,
        ),
        ProfileTile(
          icon: Icons.event_note,
          title: 'Yêu cầu đã gửi',
          subtitle: 'Xem lại các yêu cầu của bạn',
          onTap: () => context.push('/requests'),
           color: ext.card,
        ),
        const ThemeToggleTile(),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: ext.card,
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
    );
  }
}
