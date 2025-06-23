import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onToggle;
  final VoidCallback onClear;
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool hasActiveSearch;
  final String? placeholder;

  const SearchButton({
    super.key,
    required this.controller,
    required this.onToggle,
    required this.onClear,
    required this.isTablet,
    required this.colorScheme,
    required this.hasActiveSearch,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final String displayPlaceholder = placeholder ?? 'Tìm kiếm bài đăng...';

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border:
              hasActiveSearch
                  ? Border.all(
                    color: colorScheme.primary.withOpacity(0.5),
                    width: 1,
                  )
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
              size: isTablet ? 24 : 20,
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Text(
              hasActiveSearch ? controller.text : displayPlaceholder,
              style: TextStyle(
                color:
                    hasActiveSearch
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                fontSize: isTablet ? 16 : 14,
                fontWeight:
                    hasActiveSearch ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (hasActiveSearch) ...[
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.clear,
                    color: colorScheme.onSurfaceVariant,
                    size: isTablet ? 18 : 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
