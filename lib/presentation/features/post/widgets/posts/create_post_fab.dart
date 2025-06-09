import 'package:flutter/material.dart';

class CreatePostFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isTablet;
  final ColorScheme colorScheme;

  const CreatePostFAB({
    super.key,
    required this.onPressed,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        child: Icon(Icons.add, size: isTablet ? 24 : 20),
      ),
    );
  }
}