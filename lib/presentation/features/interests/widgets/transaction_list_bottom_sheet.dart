import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/data/models/transaction_model.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/domain/usecases/update_transaction_status_usecase.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/transaction_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/transactions_provider.dart';

class TransactionListBottomSheet extends HookConsumerWidget {
  final List<Transaction> transactions;
  final bool isPostOwner;
  final Function(Transaction)? onTransactionUpdated;
  final List<InterestItem> items;

  const TransactionListBottomSheet({
    super.key,
    required this.transactions,
    required this.isPostOwner,
    required this.items,
    this.onTransactionUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    // Watch transactions state để có thể refresh
    final transactionsState = ref.watch(transactionsListProvider);
    final transactionsNotifier = ref.read(transactionsListProvider.notifier);

    // Sử dụng transactions từ provider thay vì prop
    final currentTransactions = transactionsState.transactions.isNotEmpty 
        ? transactionsState.transactions 
        : transactions;

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
                  Icons.list_alt,
                  color: colorScheme.primary,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: Text(
                    isPostOwner ? 'Danh sách yêu cầu' : 'Yêu cầu của bạn',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 20 : 18,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8,
                    vertical: isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentTransactions.length}',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (transactionsState.isLoading)
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: const CircularProgressIndicator(),
            )

          // Transactions list
          else if (currentTransactions.isEmpty)
            Padding(
              padding: EdgeInsets.all(isTablet ? 48 : 32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: isTablet ? 64 : 48,
                    color: colorScheme.outline,
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Text(
                    'Chưa có yêu cầu nào',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.outline,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 8 : 4,
                ),
                itemCount: currentTransactions.length,
                separatorBuilder:
                    (context, index) => SizedBox(height: isTablet ? 12 : 8),
                itemBuilder: (context, index) {
                  final transaction = currentTransactions[index];
                  return _TransactionTile(
                    transaction: transaction,
                    isPostOwner: isPostOwner,
                    items: items,
                    onTransactionUpdated: (updatedTransaction) {
                      // Refresh transactions từ provider
                      transactionsNotifier.refresh();
                      // Gọi callback nếu có
                      onTransactionUpdated?.call(updatedTransaction);
                    },
                  );
                },
              ),
            ),

          // Safe area bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _TransactionTile extends HookConsumerWidget {
  final Transaction transaction;
  final bool isPostOwner;
  final List<InterestItem> items;
  final Function(Transaction)? onTransactionUpdated;

  const _TransactionTile({
    required this.transaction,
    required this.isPostOwner,
    required this.items,
    this.onTransactionUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    // State để track việc editing
    final isEditing = useState(false);
    final editedItems = useState<Map<int, int>>({});
    final transactionState = ref.watch(transactionProvider);
    final transactionsNotifier = ref.read(transactionsListProvider.notifier);

    final statusColor = TransactionStatus.fromValue(transaction.status).color();
    final statusText = TransactionStatus.fromValue(
      transaction.status,
    ).label(isPostOwner: isPostOwner);
    final statusIcon = TransactionStatus.fromValue(transaction.status).icon();

    // Initialize edited items map
    useEffect(() {
      editedItems.value = {
        for (final item in transaction.items) item.postItemID: item.quantity,
      };
      return null;
    }, [transaction.items]);

    void updateItemQuantity(int postItemID, int newQuantity) {
      editedItems.value = {...editedItems.value, postItemID: newQuantity};
    }

    void cancelEditing() {
      isEditing.value = false;
      editedItems.value = {
        for (final item in transaction.items) item.postItemID: item.quantity,
      };
    }

    Future<void> saveChanges() async {
      try {
        // Tạo danh sách items đã update
        final updatedItems = transaction.items.map((item) {
          final newQuantity =
              editedItems.value[item.postItemID] ?? item.quantity;
          return UpdateTransactionItemModel(
            postItemID: item.postItemID,
            quantity: newQuantity,
            transactionID: transaction.id,
          );
        }).toList();

        final updateModel = UpdateTransactionModel(
          items: updatedItems,
          status: transaction.status, // Giữ nguyên status
        );

        // Gọi update transaction
        await ref
            .read(transactionProvider.notifier)
            .updateTransaction(transaction.id, updateModel);

        if (transactionState.failure == null &&
            transactionState.updatedTransaction != null) {
          isEditing.value = false;
          
          // Refresh transactions list
          await transactionsNotifier.refresh();
          
          onTransactionUpdated?.call(transactionState.updatedTransaction!);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật giao dịch thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (transactionState.failure != null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(transactionState.failure!.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            tilePadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 8 : 4,
            ),
            childrenPadding: EdgeInsets.only(
              left: isTablet ? 16 : 12,
              right: isTablet ? 16 : 12,
              bottom: isTablet ? 16 : 12,
            ),
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: isTablet ? 20 : 16,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TimeUtils.formatTimeAgo(
                        DateTime.parse(transaction.createdAt),
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 14 : 13,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      '${transaction.items.length} món đồ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: isTablet ? 13 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 10 : 8,
                  vertical: isTablet ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: [
            // Transaction items
            ...transaction.items.map((item) {
              final maxQuantity =
                  items
                      .firstWhere((i) => item.postItemID == i.id)
                      .currentQuantity;

              return Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
                child: _EditableTransactionItem(
                  transactionItem: item,
                  transactionStatus: transaction.status,
                  isPostOwner: isPostOwner,
                  maxQuantity: maxQuantity,
                  isEditing: isEditing.value,
                  currentQuantity:
                      editedItems.value[item.postItemID] ?? item.quantity,
                  onQuantityChanged:
                      (newQuantity) =>
                          updateItemQuantity(item.postItemID, newQuantity),
                ),
              );
            }).toList(),

            // Transaction actions
            if (isPostOwner && transaction.status == 1) ...[
              SizedBox(height: isTablet ? 16 : 12),

              // Edit mode actions
              if (isEditing.value) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            transactionState.isLoading ? null : cancelEditing,
                        child: const Text('Hủy'),
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            transactionState.isLoading ? null : saveChanges,
                        child:
                            transactionState.isLoading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Lưu thay đổi'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Normal actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            () => _handleTransactionStatusUpdate(
                              ref,
                              context,
                              transaction,
                              3, // Cancelled
                              onTransactionUpdated,
                            ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 12 : 8,
                          ),
                        ),
                        child: Text(
                          'Từ chối',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          isEditing.value = true;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 12 : 8,
                          ),
                        ),
                        child: Text(
                          'Chỉnh sửa',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 12 : 8),

                // Complete transaction button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            () => _handleTransactionStatusUpdate(
                              ref,
                              context,
                              transaction,
                              2, // Success
                              onTransactionUpdated,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 12 : 8,
                          ),
                        ),
                        child: Text(
                          'Hoàn tất giao dịch',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleTransactionStatusUpdate(
    WidgetRef ref,
    BuildContext context,
    Transaction transaction,
    int newStatus,
    Function(Transaction)? onTransactionUpdated,
  ) async {
    try {
      final updateUseCase = ref.read(updateTransactionStatusUseCaseProvider);
      final transactionsNotifier = ref.read(transactionsListProvider.notifier);
      
      final result = await updateUseCase(transaction.id, newStatus);

      result.fold(
        (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (updatedTransaction) {
          // Refresh transactions list sau khi update status thành công
          transactionsNotifier.refresh();
          
          if (context.mounted) {
            final statusText = newStatus == 2 ? 'hoàn tất' : 'từ chối';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã $statusText giao dịch thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          onTransactionUpdated?.call(updatedTransaction);
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _EditableTransactionItem extends StatelessWidget {
  final TransactionItem transactionItem;
  final int transactionStatus;
  final bool isPostOwner;
  final int maxQuantity;
  final bool isEditing;
  final int currentQuantity;
  final ValueChanged<int>? onQuantityChanged;

  const _EditableTransactionItem({
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
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 600;

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

                    if (currentQuantity != transactionItem.quantity) ...[
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
}