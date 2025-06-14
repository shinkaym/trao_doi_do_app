import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/theme_extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/widgets/adaptive_app_bar.dart';

class SmartScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final AppBarType? appBarType;
  final bool? showNotification;
  final bool? showBackButton;
  final List<Widget>? appBarActions;
  final PreferredSizeWidget? appBarBottom;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;

  const SmartScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBarType,
    this.showNotification,
    this.showBackButton,
    this.appBarActions,
    this.appBarBottom,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AdaptiveAppBar.build(
        context,
        title: title,
        forceType: appBarType,
        showNotification: showNotification,
        showBackButton: showBackButton,
        actions: appBarActions,
        bottom: appBarBottom,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }
}
