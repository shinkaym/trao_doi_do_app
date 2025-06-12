import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';

class TransactionItemDetailWidget extends HookConsumerWidget {
  final TransactionItem transactionItem;
  final int maxQuantity;
  final int transactionStatus; // 1: pending, 2: accepted, 3: rejected
  final bool isPostOwner;
  final Function(int)? onQuantityUpdated;
  final VoidCallback? onConfirm;

  const TransactionItemDetailWidget({
    super.key,
    required this.transactionItem,
    required this.transactionStatus,
    required this.isPostOwner,
    required this.maxQuantity,
    this.onQuantityUpdated,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng currentQuantity để hiển thị số lượng hiện tại (có thể đã được chỉnh sửa)
    final currentQuantity = useState(transactionItem.quantity);
    final editedQuantity = useState(transactionItem.quantity);
    final isEditing = useState(false);

    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    // Determine if this item can be edited
    final canEdit =
        isPostOwner &&
        transactionStatus == 1; // Only pending transactions can be edited
    final showControls = canEdit && isEditing.value;

    void updateQuantity(int change) {
      final newQuantity = (editedQuantity.value + change).clamp(0, maxQuantity);
      editedQuantity.value = newQuantity;
      onQuantityUpdated?.call(newQuantity);
    }

    void confirmChanges() {
      // Cập nhật số lượng hiện tại khi xác nhận
      currentQuantity.value = editedQuantity.value;
      isEditing.value = false;
      onConfirm?.call();
    }

    void cancelChanges() {
      // Khôi phục lại số lượng ban đầu
      editedQuantity.value = currentQuantity.value;
      isEditing.value = false;
    }

    void startEditing() {
      // Khởi tạo editedQuantity với giá trị hiện tại khi bắt đầu chỉnh sửa
      editedQuantity.value = currentQuantity.value;
      isEditing.value = true;
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
                  child:
                      transactionItem.itemImage.isNotEmpty
                          ? Image.network(
                            transactionItem.itemImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                color: colorScheme.outline,
                                size: isTablet ? 24 : 20,
                              );
                            },
                          )
                          : Icon(
                            Icons.image,
                            color: colorScheme.outline,
                            size: isTablet ? 24 : 20,
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

                    // Quantity info - hiển thị số lượng hiện tại
                    if (transactionStatus == 2) ...[
                      // Approved quantity
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
                            '${currentQuantity.value}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Request quantity (for pending and rejected)
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
                            '${currentQuantity.value}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                          // Hiển thị indicator nếu số lượng đã được chỉnh sửa
                          if (currentQuantity.value !=
                              transactionItem.quantity) ...[
                            SizedBox(width: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
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

                    // Hiển thị số lượng gốc nếu đã chỉnh sửa
                    if (currentQuantity.value != transactionItem.quantity) ...[
                      SizedBox(height: 2),
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

          // Quantity controls (only for post owner and pending transactions)
          if (showControls) ...[
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
                          editedQuantity.value > 0
                              ? () => updateQuantity(-1)
                              : null,
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
                        '${editedQuantity.value}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          editedQuantity.value < maxQuantity
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
            SizedBox(height: isTablet ? 12 : 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: cancelChanges,
                    child: const Text('Hủy'),
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: confirmChanges,
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ],

          // Edit button (only for post owner and pending transactions)
          if (canEdit && !isEditing.value) ...[
            SizedBox(height: isTablet ? 12 : 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: startEditing,
                icon: const Icon(Icons.edit),
                label: const Text('Chỉnh sửa số lượng'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
