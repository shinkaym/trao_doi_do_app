import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final void Function(int) onTap;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      body: child,
      bottomNavigationBar: Material(
        elevation: 8,
        color: Colors.white,
        child: NavigationBar(
          backgroundColor: ext.surfaceContainer,
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: Colors.grey.shade200,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Trang chủ'),
            NavigationDestination(icon: Icon(Icons.article), label: 'Bài đăng'),
            NavigationDestination(
              icon: Icon(Icons.inventory_2),
              label: 'Kho đồ cũ',
            ),
            NavigationDestination(icon: Icon(Icons.send), label: 'Gửi đồ'),
            NavigationDestination(
              icon: Icon(Icons.leaderboard),
              label: 'Xếp hạng',
            ),
            NavigationDestination(icon: Icon(Icons.person), label: 'Hồ sơ'),
          ],
        ),
      ),
    );
  }
}
