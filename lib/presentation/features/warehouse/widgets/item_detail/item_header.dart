import 'package:flutter/material.dart';

class ItemHeader extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isLostItem;
  final String Function(DateTime) formatTime;

  const ItemHeader({
    super.key,
    required this.item,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.isLostItem,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 6 : 5,
                ),
                decoration: BoxDecoration(
                  color:
                      isLostItem
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLostItem ? Icons.help_outline : Icons.shopping_bag,
                      size: isTablet ? 16 : 14,
                      color:
                          isLostItem
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      isLostItem ? 'Đồ thất lạc' : 'Đồ cũ',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        fontWeight: FontWeight.w600,
                        color:
                            isLostItem
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 6 : 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Có sẵn',
                  style: TextStyle(
                    fontSize: isTablet ? 11 : 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            item['title'],
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: isTablet ? 18 : 16,
                color: theme.hintColor,
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Expanded(
                child: Text(
                  item['location'],
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: theme.hintColor,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Icon(
                Icons.schedule,
                size: isTablet ? 16 : 14,
                color: theme.hintColor,
              ),
              SizedBox(width: isTablet ? 4 : 3),
              Text(
                formatTime(item['createdAt']),
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
