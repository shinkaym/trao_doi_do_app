import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';

class EditableTransactionItem extends StatelessWidget {
  final TransactionItem transactionItem;
  final int transactionStatus;
  final bool isPostOwner;
  final int maxQuantity;
  final bool isEditing;
  final int currentQuantity;
  final ValueChanged<int>? onQuantityChanged;

  const EditableTransactionItem({
    super.key,
    required this.transactionItem,
    required this.transactionStatus,
    required this.isPostOwner,
    required this.maxQuantity,
    required this.isEditing,
    required this.currentQuantity,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    void updateQuantity(int change) {
      final newQuantity = (currentQuantity + change).clamp(0, maxQuantity);
      onQuantityChanged?.call(newQuantity);
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Item image
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: _buildTransactionItemImage(
                    itemImage: transactionItem.itemImage,
                    isTablet: isTablet,
                    colorScheme: colorScheme,
                  ),
                ),
              ),

              SizedBox(width: isTablet ? 16 : 12),

              // Item info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transactionItem.itemName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 6 : 4),

                    // Quantity info
                    if (transactionStatus == 2) ...[
                      Row(
                        children: [
                          Text(
                            'Chấp nhận: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                          Text(
                            '$currentQuantity',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Text(
                            'Yêu cầu: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                          Text(
                            '$currentQuantity',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                          if (currentQuantity != transactionItem.quantity) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Đã sửa',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontSize: isTablet ? 10 : 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],

                    if (currentQuantity != transactionItem.quantity) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Yêu cầu gốc: ${transactionItem.quantity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor.withOpacity(0.7),
                          fontSize: isTablet ? 11 : 10,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Quantity controls (only when editing)
          if (isEditing && isPostOwner && transactionStatus == 1) ...[
            SizedBox(height: isTablet ? 16 : 12),
            Row(
              children: [
                Text(
                  'Sẵn có: $maxQuantity',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 14 : 13,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed:
                          currentQuantity > 0 ? () => updateQuantity(-1) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$currentQuantity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          currentQuantity < maxQuantity
                              ? () => updateQuantity(1)
                              : null,
                      icon: const Icon(Icons.add_circle_outline),
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItemImage({
    required String itemImage,
    required bool isTablet,
    required ColorScheme colorScheme,
  }) {
    if (itemImage.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(itemImage);

      if (imageBytes != null) {
        return Image.memory(imageBytes, fit: BoxFit.cover);
      }
    }

    return Icon(
      Icons.image,
      color: colorScheme.outline,
      size: isTablet ? 24 : 20,
    );
  }
}
