import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/request/transaction_request.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/transaction_provider.dart';

class TransactionItemSelectionBottomSheet extends HookConsumerWidget {
  final List<InterestItem> postItems;
  final int interestId;
  final VoidCallback? onTransactionSent;

  const TransactionItemSelectionBottomSheet({
    super.key,
    required this.postItems,
    required this.interestId,
    this.onTransactionSent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems = useState<Map<int, int>>({});

    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    // Listen to transaction state
    final transactionState = ref.watch(transactionProvider);

    // Listen to state changes for success/error handling
    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (next.failure != null) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.failure!.message),
              backgroundColor: colorScheme.error,
            ),
          );
        } else if (next.createdTransaction != null) {
          // Success - close bottom sheet and show success message
          Navigator.of(context).pop();
          onTransactionSent?.call();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                next.successMessage ?? 'Đã gửi yêu cầu thành công!',
              ),
              backgroundColor: colorScheme.primary,
            ),
          );

          // Clear the state after success
          Future.delayed(const Duration(milliseconds: 500), () {
            ref.read(transactionProvider.notifier).clearState();
          });
        }
      }
    });

    void updateQuantity(int id, int change) {
      final currentQuantity = selectedItems.value[id] ?? 0;
      final newQuantity =
          (currentQuantity + change).clamp(0, double.infinity).toInt();

      if (newQuantity == 0) {
        final newMap = Map<int, int>.from(selectedItems.value);
        newMap.remove(id);
        selectedItems.value = newMap;
      } else {
        selectedItems.value = {...selectedItems.value, id: newQuantity};
      }
    }

    void submitTransaction() {
      if (selectedItems.value.isEmpty || transactionState.isLoading) return;

      // Create transaction items from selected items
      final transactionItems =
          selectedItems.value.entries
              .map(
                (entry) => CreateTransactionItemRequest(
                  postItemID: entry.key,
                  quantity: entry.value,
                ),
              )
              .toList();

      // Create transaction model
      final create = CreateTransactionRequest(
        interestID: interestId,
        items: transactionItems,
      );

      // Call the provider to create transaction
      ref.read(transactionProvider.notifier).createTransaction(create);
    }

    final hasSelectedItems = selectedItems.value.isNotEmpty;
    final isLoading = transactionState.isLoading;

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
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Error display
          if (transactionState.failure != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transactionState.failure!.message,
                      style: TextStyle(
                        color: colorScheme.error,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Items list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                isTablet ? 24 : 16,
                transactionState.failure != null ? 16 : 0,
                isTablet ? 24 : 16,
                0,
              ),
              itemCount: postItems.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: isTablet ? 24 : 16,
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
              itemBuilder: (context, index) {
                final item = postItems[index];
                final selectedQuantity = selectedItems.value[item.id] ?? 0;
                final maxQuantity = item.currentQuantity;

                return Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color:
                        selectedQuantity > 0
                            ? colorScheme.primaryContainer.withOpacity(0.3)
                            : colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          selectedQuantity > 0
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
                          child: _buildItemImage(
                            item.image,
                            isTablet,
                            colorScheme,
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
                            onPressed:
                                selectedQuantity > 0 && !isLoading
                                    ? () => updateQuantity(item.id, -1)
                                    : null,
                            icon: const Icon(Icons.remove),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  selectedQuantity > 0
                                      ? colorScheme.primary.withOpacity(0.1)
                                      : colorScheme.outline.withOpacity(0.1),
                              foregroundColor:
                                  selectedQuantity > 0
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
                            onPressed:
                                selectedQuantity < maxQuantity && !isLoading
                                    ? () => updateQuantity(item.id, 1)
                                    : null,
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  selectedQuantity < maxQuantity
                                      ? colorScheme.primary.withOpacity(0.1)
                                      : colorScheme.outline.withOpacity(0.1),
                              foregroundColor:
                                  selectedQuantity < maxQuantity
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
                onPressed:
                    hasSelectedItems && !isLoading ? submitTransaction : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    isLoading
                        ? SizedBox(
                          height: isTablet ? 20 : 16,
                          width: isTablet ? 20 : 16,
                          child: CircularProgressIndicator(
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

Widget _buildItemImage(
  String itemImage,
  bool isTablet,
  ColorScheme colorScheme,
) {
  if (itemImage.isNotEmpty) {
    final imageBytes = Base64Utils.decodeImageFromBase64(itemImage);

    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.memory(imageBytes, fit: BoxFit.cover),
      );
    }
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(7),
    child: Icon(
      Icons.image,
      color: colorScheme.outline,
      size: isTablet ? 24 : 20,
    ),
  );
}
