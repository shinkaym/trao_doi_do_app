import 'package:flutter/material.dart';

class PickupOptions extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const PickupOptions({
    super.key,
    required this.item,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final pickupOptions = List<Map<String, dynamic>>.from(
      item['pickupOptions'],
    );

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
            'Cách thức nhận đồ',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ...pickupOptions
              .map(
                (option) => Container(
                  margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color:
                        option['available']
                            ? colorScheme.primary.withOpacity(0.05)
                            : colorScheme.outline.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          option['available']
                              ? colorScheme.primary.withOpacity(0.2)
                              : colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        option['available'] ? Icons.check_circle : Icons.cancel,
                        size: isTablet ? 20 : 18,
                        color:
                            option['available']
                                ? colorScheme.primary
                                : theme.hintColor,
                      ),
                      SizedBox(width: isTablet ? 12 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['label'],
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    option['available']
                                        ? colorScheme.onSurface
                                        : theme.hintColor,
                              ),
                            ),
                            SizedBox(height: isTablet ? 4 : 2),
                            Text(
                              option['description'],
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 11,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
