import 'package:flutter/material.dart';

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
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.article), label: 'Bài đăng'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Kho đồ'),
          NavigationDestination(icon: Icon(Icons.send), label: 'Gửi đồ'),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Xếp hạng',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
