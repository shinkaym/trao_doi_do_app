import 'package:flutter/material.dart';

class Shimmer extends StatelessWidget {
  final double width;
  final double height;
  final ColorScheme colorScheme;

  const Shimmer({
    super.key,
    required this.width,
    required this.height,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
