import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/core/constants/app_bar_config.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

class AdaptiveAppBar {
  static PreferredSizeWidget? build(
    BuildContext context, {
    String? title,
    AppBarType? forceType,
    bool? showNotification,
    bool? showBackButton,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  }) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final config = AppBarConfig.getConfigForRoute(currentRoute);

    if (config == null && forceType == null) return null;

    final type = forceType ?? config?.type ?? AppBarType.standard;
    final appBarTitle = title ?? config?.title ?? '';
    final showNotif = showNotification ?? config?.showNotification ?? true;
    final showBack = showBackButton ?? config?.showBackButton ?? false;

    switch (type) {
      case AppBarType.standard:
        return CustomAppBar(
          title: appBarTitle,
          showNotificationButton: showNotif,
          showBackButton: showBack,
          additionalActions: actions,
          bottom: bottom,
        );

      case AppBarType.minimal:
        return CustomAppBar(
          title: appBarTitle,
          showNotificationButton: false,
          showBackButton: showBack,
          additionalActions: actions,
          bottom: bottom,
        );

      case AppBarType.detail:
      case AppBarType.chat:
        // Những screen này tự handle AppBar
        return null;
    }
  }
}
