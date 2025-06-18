import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/constants/nav_bar_constants.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_navigation_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final bool showNavBar;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.currentIndex,
    this.showNavBar = true,
  });

  void _onNavTap(BuildContext context, int index) {
    if (index != currentIndex && index < NavBarConstants.routes.length) {
      context.go(NavBarConstants.routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar:
          showNavBar
              ? CustomBottomNavigation(
                currentIndex: currentIndex,
                onTap: (index) => _onNavTap(context, index),
                showLabels: true,
              )
              : null,
    );
  }
}
