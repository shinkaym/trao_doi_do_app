import 'package:flutter/material.dart';

class LoadingItem extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const LoadingItem({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
