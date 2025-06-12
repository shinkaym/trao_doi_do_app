import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/features/interests/screens/interest_chat_screen.dart';

class RequestItemSelectionBottomSheet extends HookConsumerWidget {
  final List<PostItem> postItems;
  final VoidCallback? onRequestSent;

  const RequestItemSelectionBottomSheet({
    super.key,
    required this.postItems,
    this.onRequestSent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems = useState<Map<String, int>>({});
    final isSubmitting = useState(false);

    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    void updateQuantity(String itemId, int change) {
      final currentQuantity = selectedItems.value[itemId] ?? 0;
      final newQuantity = (currentQuantity + change).clamp(0, double.infinity).toInt();
      
      if (newQuantity == 0) {
        final newMap = Map<String, int>.from(selectedItems.value);
        newMap.remove(itemId);
        selectedItems.value = newMap;
      } else {
        selectedItems.value = {
          ...selectedItems.value,
          itemId: newQuantity,
        };
      }
    }

    void submitRequest() async {
      if (selectedItems.value.isEmpty || isSubmitting.value) return;

      isSubmitting.value = true;

      try {
        // TODO: Call API to submit request
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        
        Navigator.of(context).pop();
        onRequestSent?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi yêu cầu thành công!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi gửi yêu cầu: $e')),
        );
      } finally {
        isSubmitting.value = false;
      }
    }

    final hasSelectedItems = selectedItems.value.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: colorScheme.primary,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: Text(
                    'Chọn món đồ cần xin',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 20 : 18,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Items list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
              itemCount: postItems.length,
              separatorBuilder: (context, index) => Divider(
                height: isTablet ? 24 : 16,
                color: colorScheme.outline.withOpacity(0.2),
              ),
              itemBuilder: (context, index) {
                final item = postItems[index];
                final selectedQuantity = selectedItems.value[item.id] ?? 0;
                final maxQuantity = item.quantity;

                return Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: selectedQuantity > 0 
                        ? colorScheme.primaryContainer.withOpacity(0.3)
                        : colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedQuantity > 0
                          ? colorScheme.primary.withOpacity(0.3)
                          : colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Item image
                      Container(
                        width: isTablet ? 60 : 50,
                        height: isTablet ? 60 : 50,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: item.image.isNotEmpty
                              ? Image.network(
                                  item.image,
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
                              item.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 16 : 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isTablet ? 4 : 2),
                            Text(
                              'Có sẵn: $maxQuantity',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                                fontSize: isTablet ? 13 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quantity controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: selectedQuantity > 0
                                ? () => updateQuantity(item.id, -1)
                                : null,
                            icon: const Icon(Icons.remove),
                            style: IconButton.styleFrom(
                              backgroundColor: selectedQuantity > 0
                                  ? colorScheme.primary.withOpacity(0.1)
                                  : colorScheme.outline.withOpacity(0.1),
                              foregroundColor: selectedQuantity > 0
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              minimumSize: Size(
                                isTablet ? 40 : 32,
                                isTablet ? 40 : 32,
                              ),
                            ),
                          ),

                          Container(
                            width: isTablet ? 50 : 40,
                            alignment: Alignment.center,
                            child: Text(
                              selectedQuantity.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: selectedQuantity < maxQuantity
                                ? () => updateQuantity(item.id, 1)
                                : null,
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor: selectedQuantity < maxQuantity
                                  ? colorScheme.primary.withOpacity(0.1)
                                  : colorScheme.outline.withOpacity(0.1),
                              foregroundColor: selectedQuantity < maxQuantity
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              minimumSize: Size(
                                isTablet ? 40 : 32,
                                isTablet ? 40 : 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Submit button
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasSelectedItems && !isSubmitting.value
                    ? submitRequest
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 16 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting.value
                    ? SizedBox(
                        height: isTablet ? 20 : 16,
                        width: isTablet ? 20 : 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        hasSelectedItems
                            ? 'Gửi yêu cầu (${selectedItems.value.length} món)'
                            : 'Chọn ít nhất 1 món đồ',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),

          // Safe area bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

