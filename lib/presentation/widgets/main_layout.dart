import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/shared_app_bar.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final int notificationCount;
  final List<Widget>? actions;

  const MainLayout({
    super.key,
    required this.title,
    required this.child,
    this.notificationCount = 0,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: title,
        notificationCount: notificationCount,
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [child],
          ),
        ),
      ),
    );
  }
}
