import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ItemDescription extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final ValueNotifier<bool> showFullDescription;

  const ItemDescription({
    super.key,
    required this.item,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.showFullDescription,
  });

  @override
  Widget build(BuildContext context) {
    final description = item['description'];
    final isLongDescription = description.length > 150;

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          ValueListenableBuilder<bool>(
            valueListenable: showFullDescription,
            builder: (context, showFull, child) {
              return Text(
                isLongDescription && !showFull
                    ? '${description.substring(0, 150)}...'
                    : description,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              );
            },
          ),
          if (isLongDescription) ...[
            SizedBox(height: isTablet ? 8 : 6),
            ValueListenableBuilder<bool>(
              valueListenable: showFullDescription,
              builder: (context, showFull, child) {
                return GestureDetector(
                  onTap: () {
                    showFullDescription.value = !showFullDescription.value;
                  },
                  child: Text(
                    showFull ? 'Thu gọn' : 'Xem thêm',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
