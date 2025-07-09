import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class AppBarConfig {
  final AppBarType type;
  final String title;
  final bool showNotification;
  final bool showBackButton;
  final bool showSearchButton;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const AppBarConfig({
    required this.type,
    required this.title,
    this.showNotification = true,
    this.showBackButton = false,
    this.showSearchButton = false,
    this.actions,
    this.bottom,
  });

  static const Map<String, AppBarConfig> screenConfigs = {
    '/home': AppBarConfig(
      type: AppBarType.standard,
      title: 'Share And Save',
      showNotification: true,
    ),
    '/posts': AppBarConfig(
      type: AppBarType.standard,
      title: 'Bài đăng',
      showNotification: true,
    ),
    '/warehouse': AppBarConfig(
      type: AppBarType.standard,
      title: 'Kho đồ',
      showNotification: true,
    ),
    '/interests': AppBarConfig(
      type: AppBarType.standard,
      title: 'Quan tâm',
      showNotification: true,
    ),
    '/profile': AppBarConfig(
      type: AppBarType.standard,
      title: 'Hồ sơ',
      showNotification: true,
    ),

    // Auth screens - không yêu cầu đăng nhập
    '/login': AppBarConfig(
      type: AppBarType.minimal,
      title: 'Đăng nhập',
      showNotification: false,
    ),
    '/register': AppBarConfig(
      type: AppBarType.minimal,
      title: 'Đăng ký',
      showNotification: false,
      showBackButton: true,
    ),
    '/forgot-password': AppBarConfig(
      type: AppBarType.minimal,
      title: 'Quên mật khẩu',
      showNotification: false,
      showBackButton: true,
    ),
    '/reset-password': AppBarConfig(
      type: AppBarType.minimal,
      title: 'Đặt lại mật khẩu',
      showNotification: false,
      showBackButton: true,
    ),

    // Sub screens - yêu cầu đăng nhập
    '/posts/create-post': AppBarConfig(
      type: AppBarType.standard,
      title: 'Tạo bài đăng',
      showNotification: true,
      showBackButton: true,
    ),
    '/profile/edit': AppBarConfig(
      type: AppBarType.standard,
      title: 'Chỉnh sửa thông tin',
      showNotification: true,
      showBackButton: true,
    ),
    '/profile/change-password': AppBarConfig(
      type: AppBarType.standard,
      title: 'Đổi mật khẩu',
      showNotification: true,
      showBackButton: true,
    ),
    '/profile/my-posts': AppBarConfig(
      type: AppBarType.standard,
      title: 'Bài đăng của tôi',
      showNotification: true,
      showBackButton: true,
    ),
    '/profile/ranking': AppBarConfig(
      type: AppBarType.standard,
      title: 'Xếp hạng',
      showNotification: true,
      showBackButton: true,
    ),
    '/profile/appointments': AppBarConfig(
      type: AppBarType.standard,
      title: 'Cuộc hẹn',
      showNotification: true,
      showBackButton: true,
    ),
    '/notifications': AppBarConfig(
      type: AppBarType.minimal,
      title: 'Thông báo',
      showNotification: false,
      showBackButton: true,
    ),

    // Special screens
    '/posts/post-detail': AppBarConfig(type: AppBarType.detail, title: ''),
    '/warehouse/item-detail': AppBarConfig(type: AppBarType.detail, title: ''),
    '/interests/chat': AppBarConfig(type: AppBarType.chat, title: ''),
  };

  static AppBarConfig? getConfigForRoute(String route) {
    // Exact match first
    if (screenConfigs.containsKey(route)) {
      return screenConfigs[route];
    }

    // Pattern matching for dynamic routes
    for (final entry in screenConfigs.entries) {
      if (_matchesPattern(route, entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  static bool _matchesPattern(String route, String pattern) {
    // Handle dynamic segments like :id
    final patternParts = pattern.split('/');
    final routeParts = route.split('/');

    if (patternParts.length != routeParts.length) return false;

    for (int i = 0; i < patternParts.length; i++) {
      if (patternParts[i].startsWith(':')) continue; // Dynamic segment
      if (patternParts[i] != routeParts[i]) return false;
    }

    return true;
  }
}
