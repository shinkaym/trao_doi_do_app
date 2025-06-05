import 'package:flutter/material.dart';

class ItemRules extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const ItemRules({
    super.key,
    required this.item,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final rules = List<String>.from(item['rules']);

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
          Row(
            children: [
              Icon(
                Icons.rule_outlined,
                size: isTablet ? 20 : 18,
                color: colorScheme.primary,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Quy định khi nhận đồ',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ...rules
              .map(
                (rule) => Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isTablet ? 6 : 5,
                        height: isTablet ? 6 : 5,
                        margin: EdgeInsets.only(
                          top: isTablet ? 6 : 5,
                          right: isTablet ? 12 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          rule,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: colorScheme.onSurface,
                            height: 1.4,
                          ),
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
