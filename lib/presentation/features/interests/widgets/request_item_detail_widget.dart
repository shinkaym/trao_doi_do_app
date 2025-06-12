import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/features/interests/screens/interest_chat_screen.dart';

class RequestItemDetailWidget extends HookConsumerWidget {
  final RequestItem requestItem;
  final int requestStatus; // 0: pending, 1: accepted, 2: rejected
  final bool isPostOwner;
  final Function(int)? onQuantityUpdated;
  final VoidCallback? onConfirm;

  const RequestItemDetailWidget({
    super.key,
    required this.requestItem,
    required this.requestStatus,
    required this.isPostOwner,
    this.onQuantityUpdated,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvedQuantity = useState(requestItem.approvedQuantity ?? 0);
    final isEditing = useState(false);

    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    // Determine if this item can be edited
    final canEdit = isPostOwner && requestStatus == 0; // Only pending requests can be edited
    final showControls = canEdit && isEditing.value;

    void updateQuantity(int change) {
      final newQuantity = (approvedQuantity.value + change)
          .clamp(0, requestItem.requestedQuantity);
      approvedQuantity.value = newQuantity;
      onQuantityUpdated?.call(newQuantity);
    }

    void confirmChanges() {
      isEditing.value = false;
      onConfirm?.call();
    }

    void cancelChanges() {
      approvedQuantity.value = requestItem.approvedQuantity ?? 0;
      isEditing.value = false;
    }

    // Status colors and indicators
    Color statusColor = Colors.grey;
    String statusText = '';
    
    if (requestStatus == 0) {
      statusColor = Colors.orange;
      statusText = isPostOwner ? 'Chưa xử lý' : 'Đang chờ';
    } else if (requestStatus == 1) {
      statusColor = Colors.green;
      statusText = 'Đã chấp nhận';
    } else if (requestStatus == 2) {
      statusColor = Colors.red;
      statusText = 'Đã từ chối';
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
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
                  child: requestItem.itemImage.isNotEmpty
                      ? Image.network(
                          requestItem.itemImage,
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
                      requestItem.itemName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    
                    // Quantity info
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
                          '${requestItem.requestedQuantity}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 13 : 12,
                          ),
                        ),
                      ],
                    ),

                    // Approved quantity (if applicable)
                    if (requestStatus == 1 && (requestItem.approvedQuantity ?? 0) > 0) ...[
                      SizedBox(height: isTablet ? 4 : 2),
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
                            '${requestItem.approvedQuantity}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 8 : 6,
                  vertical: isTablet ? 4 : 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: isTablet ? 11 : 10,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Quantity controls (only for post owner and pending requests)
          if (showControls) ...[
            SizedBox(height: isTablet ? 16 : 12),
            Row(
              children: [
                Text(
                  'Số lượng chấp nhận:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 14 : 13,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => updateQuantity(-1),
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
                        '${approvedQuantity.value}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => updateQuantity(1),
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

          // Edit button (only for post owner and pending requests)
          if (canEdit && !isEditing.value) ...[
            SizedBox(height: isTablet ? 12 : 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => isEditing.value = true,
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