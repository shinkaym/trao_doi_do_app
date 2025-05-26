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
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 72,
            backgroundColor: ext.surfaceContainer, // Màu nền của NavigationBar
            indicatorColor: ext.primary, // Màu nền tròn khi chọn
            indicatorShape: const CircleBorder(), // Hình tròn cho indicator
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(
                    color: ext.onPrimary, // Màu icon khi được chọn
                    size: 24, // Kích thước icon
                  );
                }
                return IconThemeData(
                  color: ext.secondaryTextColor, // Màu icon khi không chọn
                  size: 24,
                );
              },
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              _buildNavDestination(Icons.home, 'Trang chủ', ext),
              _buildNavDestination(Icons.article, 'Bài đăng', ext),
              _buildNavDestination(Icons.inventory_2, 'Kho đồ cũ', ext),
              _buildNavDestination(Icons.send, 'Gửi đồ', ext),
              _buildNavDestination(Icons.leaderboard, 'Xếp hạng', ext),
              _buildNavDestination(Icons.person, 'Hồ sơ', ext),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo NavigationDestination với icon tròn
  NavigationDestination _buildNavDestination(IconData icon, String label, AppThemeExtension ext) {
    return NavigationDestination(
      icon: Container(
        padding: const EdgeInsets.all(8), // Khoảng cách bên trong để tạo vòng tròn lớn hơn
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Hình tròn
          color: Colors.transparent, // Không màu nền khi không chọn
        ),
        child: Icon(icon),
      ),
      selectedIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ext.primary, // Màu nền tròn khi được chọn
        ),
        child: Icon(
          icon,
          color: ext.onPrimary, // Màu icon khi được chọn
        ),
      ),
      label: label,
    );
  }
}