import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/transaction_item_detail_widget.dart';

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

    // Sort transactions by created date (newest first)
    final sortedTransactions = [...transactions]
      ..sort((a, b) => (b.createdAt).compareTo(a.createdAt));

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
                    '${transactions.length}',
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

          // Transactions list
          if (transactions.isEmpty)
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
                itemCount: sortedTransactions.length,
                separatorBuilder:
                    (context, index) => SizedBox(height: isTablet ? 12 : 8),
                itemBuilder: (context, index) {
                  final transaction = sortedTransactions[index];
                  return _buildTransactionTile(
                    transaction,
                    theme,
                    colorScheme,
                    isTablet,
                    isPostOwner,
                    items,
                    onTransactionUpdated,
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

  Widget _buildTransactionTile(
    Transaction transaction,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
    bool isPostOwner,
    List<InterestItem> items,
    Function(Transaction)? onTransactionUpdated,
  ) {
    final statusColor = TransactionStatus.fromValue(transaction.status).color();
    final statusText = TransactionStatus.fromValue(
      transaction.status,
    ).label(isPostOwner: isPostOwner);
    final statusIcon = TransactionStatus.fromValue(transaction.status).icon();

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
              return Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
                child: TransactionItemDetailWidget(
                  transactionItem: item,
                  transactionStatus: transaction.status,
                  isPostOwner: isPostOwner,
                  maxQuantity:
                      items
                          .firstWhere((i) => item.postItemID == i.id)
                          .currentQuantity,
                  onQuantityUpdated: (newQuantity) {
                    // TODO: Handle quantity update
                    // This should update the item's approved quantity
                    // and call onTransactionUpdated with the modified transaction
                  },
                  onConfirm: () {
                    // TODO: Handle confirm action
                    // This should accept/reject the transaction
                    // and call onTransactionUpdated with the modified transaction
                  },
                ),
              );
            }).toList(),

            // Transaction actions (for post owner with pending transactions)
            if (isPostOwner && transaction.status == 1) ...[
              SizedBox(height: isTablet ? 16 : 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Reject transaction
                        _handleTransactionAction(
                          transaction,
                          2,
                          onTransactionUpdated,
                        );
                      },
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
                        // TODO: Accept transaction
                        _handleTransactionAction(
                          transaction,
                          1,
                          onTransactionUpdated,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 12 : 8,
                        ),
                      ),
                      child: Text(
                        'Chấp nhận',
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
        ),
      ),
    );
  }

  void _handleTransactionAction(
    Transaction transaction,
    int newStatus,
    Function(Transaction)? onTransactionUpdated,
  ) {
    // TODO: Implement API call to update transaction status
  }
}
