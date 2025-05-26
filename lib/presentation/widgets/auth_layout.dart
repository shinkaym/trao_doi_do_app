import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AuthLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: ext.secondary, // Set the color of the back button
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 32),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
