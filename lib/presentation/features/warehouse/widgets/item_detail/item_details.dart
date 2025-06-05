import 'package:flutter/material.dart';

class ItemDetails extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const ItemDetails({
    super.key,
    required this.item,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final details = [
      {
        'icon': Icons.category_outlined,
        'label': 'Danh mục',
        'value': item['category'],
      },
      {
        'icon': Icons.star_outline,
        'label': 'Tình trạng',
        'value': item['condition'],
      },
      if (item['size'] != null)
        {'icon': Icons.straighten, 'label': 'Kích cỡ', 'value': item['size']},
      if (item['brand'] != null)
        {
          'icon': Icons.local_offer_outlined,
          'label': 'Thương hiệu',
          'value': item['brand'],
        },
      if (item['color'] != null)
        {
          'icon': Icons.palette_outlined,
          'label': 'Màu sắc',
          'value': item['color'],
        },
      if (item['material'] != null)
        {
          'icon': Icons.texture,
          'label': 'Chất liệu',
          'value': item['material'],
        },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
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
            'Thông tin chi tiết',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ...details
              .map(
                (detail) => Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                  child: Row(
                    children: [
                      Icon(
                        detail['icon'] as IconData,
                        size: isTablet ? 20 : 18,
                        color: theme.hintColor,
                      ),
                      SizedBox(width: isTablet ? 12 : 10),
                      Text(
                        '${detail['label']}:',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: theme.hintColor,
                        ),
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Expanded(
                        child: Text(
                          detail['value'] as String,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
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
