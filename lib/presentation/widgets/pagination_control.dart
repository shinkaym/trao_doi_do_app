// pagination_controls.dart
import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class PaginationControls extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final void Function(int page) onPageChanged;

  const PaginationControls({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        children: List.generate(totalPages, (i) {
          final page = i + 1;
          final isSelected = page == currentPage;

          return InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => onPageChanged(page),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? ext.primary : ext.surfaceContainer,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? ext.primary : ext.accentLight,
                ),
              ),
              child: Text(
                '$page',
                style: TextStyle(
                  color: isSelected ? ext.onPrimary : ext.primaryTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
