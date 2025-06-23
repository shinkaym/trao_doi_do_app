import 'package:flutter/material.dart';

class CreatePostButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isTablet;
  final ColorScheme colorScheme;

  const CreatePostButton({
    super.key,
    required this.onPressed,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add,
            color: colorScheme.onPrimary,
            size: isTablet ? 24 : 20,
          ),
        ),
      ),
    );
  }
}
