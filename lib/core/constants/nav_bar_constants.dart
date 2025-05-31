import 'package:flutter/material.dart';

class NavBarConstants {
  // Main routes cho bottom navigation
  static const List<String> routes = [
    '/posts',
    '/warehouse',
    '/interests',
    '/ranking',
    '/profile',
  ];

  // Navigation items configuration
  static const List<NavigationItemConfig> navigationItems = [
    NavigationItemConfig(
      label: 'Bài đăng',
      activeIcon: Icons.article,
      inactiveIcon: Icons.article_outlined,
      route: '/posts',
      index: 0,
    ),
    NavigationItemConfig(
      label: 'Kho đồ',
      activeIcon: Icons.inventory,
      inactiveIcon: Icons.inventory_2_outlined,
      route: '/warehouse',
      index: 1,
    ),
    NavigationItemConfig(
      label: 'Quan tâm',
      activeIcon: Icons.favorite,
      inactiveIcon: Icons.favorite_border,
      route: '/interests',
      index: 2,
    ),
    NavigationItemConfig(
      label: 'Xếp hạng',
      activeIcon: Icons.leaderboard,
      inactiveIcon: Icons.leaderboard_outlined,
      route: '/ranking',
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

  // Map route patterns với parent route để xử lý sub-routes
  static const Map<String, String> subRouteMapping = {
    // Posts related routes
    '/posts/post-detail': '/posts',

    // Warehouse related routes
    '/warehouse/item-detail': '/warehouse',

    // Interests related routes
    '/interests/chat': '/interests',

    // Profile related routes
    '/profile/edit': '/profile',
    '/profile/change-password': '/profile',
    '/profile/requests': '/profile',
    '/profile/requests/detail': '/profile',
  };

  // Routes không thuộc bottom navigation
  static const List<String> excludedRoutes = [
    '/splash',
    '/onboarding',
    '/login',
    '/register',
    '/forgot-password',
    '/reset-password',
    '/notifications',
  ];

  // Helper method để get parent route
  static String getParentRoute(String currentRoute) {
    // Kiểm tra sub-route mapping trước
    for (final entry in subRouteMapping.entries) {
      if (currentRoute.startsWith(entry.key)) {
        return entry.value;
      }
    }

    // Kiểm tra main routes
    for (final route in routes) {
      if (currentRoute.startsWith(route)) {
        return route;
      }
    }

    return '/posts'; // Default fallback
  }

  // Helper method để get navigation index
  static int getNavigationIndex(String currentRoute) {
    final parentRoute = getParentRoute(currentRoute);
    final index = routes.indexOf(parentRoute);
    return index >= 0 ? index : 0;
  }

  // Helper method để check nếu route có bottom navigation
  static bool hasBottomNavigation(String route) {
    return !excludedRoutes.any((excluded) => route.startsWith(excluded));
  }
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

  // Helper method để check nếu item này active
  bool isActive(String currentRoute) {
    final parentRoute = NavBarConstants.getParentRoute(currentRoute);
    return parentRoute == route;
  }
}
