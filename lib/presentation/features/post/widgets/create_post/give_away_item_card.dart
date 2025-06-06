import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/models/give_away_item.dart';

class GiveAwayItemCard extends StatelessWidget {
  final GiveAwayItem item;
  final bool isTablet;
  final VoidCallback onRemove;

  const GiveAwayItemCard({
    super.key,
    required this.item,
    required this.isTablet,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        child: Row(
          children: [
            Container(
              width: isTablet ? 60 : 50,
              height: isTablet ? 60 : 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surfaceVariant,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    item.imageData != null
                        ? Image.memory(item.imageData!, fit: BoxFit.cover)
                        : Icon(
                          Icons.image,
                          color: colorScheme.onSurfaceVariant,
                        ),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description?.isNotEmpty == true) ...[
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      item.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: isTablet ? 4 : 2),
                  Row(
                    children: [
                      Icon(
                        Icons.numbers,
                        size: isTablet ? 16 : 14,
                        color: theme.hintColor,
                      ),
                      SizedBox(width: isTablet ? 4 : 2),
                      Text(
                        'Số lượng: ${item.quantity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.delete_outline, color: Colors.red),
              constraints: BoxConstraints(
                minWidth: isTablet ? 40 : 32,
                minHeight: isTablet ? 40 : 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
