import 'package:flutter/material.dart';

class AppointmentsTopActionBar extends StatelessWidget {
  final VoidCallback onFilterPressed;
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool hasActiveFilters;

  const AppointmentsTopActionBar({
    super.key,
    required this.onFilterPressed,
    required this.isTablet,
    required this.colorScheme,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Filter Button
          AppointmentsFilterButton(
            onPressed: onFilterPressed,
            isTablet: isTablet,
            colorScheme: colorScheme,
            hasActiveFilters: hasActiveFilters,
          ),
        ],
      ),
    );
  }
}

class AppointmentsFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool hasActiveFilters;

  const AppointmentsFilterButton({
    super.key,
    required this.onPressed,
    required this.isTablet,
    required this.colorScheme,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: hasActiveFilters ? 2 : 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color:
                hasActiveFilters
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border:
                hasActiveFilters
                    ? Border.all(color: colorScheme.primary.withOpacity(0.3))
                    : null,
          ),
          child: Icon(
            hasActiveFilters ? Icons.filter_alt : Icons.tune,
            color:
                hasActiveFilters
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
            size: isTablet ? 24 : 20,
          ),
        ),
      ),
    );
  }
}
