import 'package:flutter/material.dart';

class NavBarConstants {
  // Main routes cho bottom navigation - với home làm màn hình chính
  static const List<String> routes = [
    '/home', // Màn hình chính
    '/posts', // Bài đăng
    '/warehouse', // Kho đồ
    '/interests', // Quan tâm
    '/profile', // Hồ sơ (bao gồm ranking)
  ];

  // Navigation items configuration - 5 tab chính
  static const List<NavigationItemConfig> navigationItems = [
    NavigationItemConfig(
      label: 'Trang chủ',
      activeIcon: Icons.home,
      inactiveIcon: Icons.home_outlined,
      route: '/home',
      index: 0,
    ),
    NavigationItemConfig(
      label: 'Bài đăng',
      activeIcon: Icons.article,
      inactiveIcon: Icons.article_outlined,
      route: '/posts',
      index: 1,
    ),
    NavigationItemConfig(
      label: 'Kho đồ',
      activeIcon: Icons.inventory,
      inactiveIcon: Icons.inventory_2_outlined,
      route: '/warehouse',
      index: 2,
    ),
    NavigationItemConfig(
      label: 'Quan tâm',
      activeIcon: Icons.favorite,
      inactiveIcon: Icons.favorite_border,
      route: '/interests',
      index: 3,
    ),
    NavigationItemConfig(
      label: 'Hồ sơ',
      activeIcon: Icons.person,
      inactiveIcon: Icons.person_outline,
      route: '/profile',
      index: 4,
    ),
  ];
}

class NavigationItemConfig {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String route;
  final int index;
  final bool isSpecial;

  const NavigationItemConfig({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.route,
    required this.index,
    this.isSpecial = false,
  });
}
