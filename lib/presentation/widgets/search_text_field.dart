import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback onToggle;
  final VoidCallback onClear;
  final bool isTablet;
  final ColorScheme colorScheme;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onToggle,
    required this.onClear,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: colorScheme.primary,
            size: isTablet ? 20 : 18,
          ),
          SizedBox(width: isTablet ? 8 : 6),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Nhập từ khóa tìm kiếm...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
          if (controller.text.isNotEmpty) ...[
            SizedBox(width: isTablet ? 8 : 4),
            InkWell(
              onTap: () {
                controller.clear();
                onClear();
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.clear,
                  color: colorScheme.onSurfaceVariant,
                  size: isTablet ? 16 : 14,
                ),
              ),
            ),
          ],
          SizedBox(width: isTablet ? 8 : 4),
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.keyboard_arrow_up,
                color: colorScheme.onSurfaceVariant,
                size: isTablet ? 20 : 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
