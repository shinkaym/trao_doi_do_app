import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/transaction_list_bottom_sheet/transaction_tile.dart';

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
    final currentTransactions =
        transactionsState.transactions.isNotEmpty
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
                  return TransactionTile(
                    transaction: transaction,
                    isPostOwner: isPostOwner,
                    items: items,
                    index: index,
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
