import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/core/constants/nav_bar_constants.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_navigation_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ScaffoldWithNavBar({
    Key? key,
    required this.child,
    required this.currentIndex,
  }) : super(key: key);

  void _onNavTap(BuildContext context, int index) {
    if (index != currentIndex && index < NavBarConstants.routes.length) {
      context.go(NavBarConstants.routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) => _onNavTap(context, index),
        showLabels: true,
      ),
    );
  }
}