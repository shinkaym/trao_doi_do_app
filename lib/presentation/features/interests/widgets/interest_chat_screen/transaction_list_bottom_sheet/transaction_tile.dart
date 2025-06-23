import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/request/transaction_request.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/transaction_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/transaction_list_bottom_sheet/delivery_method_selector.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/transaction_list_bottom_sheet/editable_transaction_item.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/transaction_list_bottom_sheet/transaction_action_buttons.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/transaction_list_bottom_sheet/transaction_status_helpers.dart';

class TransactionTile extends HookConsumerWidget {
  final Transaction transaction;
  final bool isPostOwner;
  final List<InterestItem> items;
  final Function(Transaction)? onTransactionUpdated;
  final int index;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.isPostOwner,
    required this.items,
    required this.index,
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
    final selectedDeliveryMethod = useState<DeliveryMethod>(
      transaction.method == DeliveryMethod.delivery.value
          ? DeliveryMethod.delivery
          : DeliveryMethod.meetInPerson,
    );
    final transactionState = ref.watch(transactionProvider);
    final transactionsNotifier = ref.read(transactionsListProvider.notifier);

    final statusColor = TransactionStatus.fromValue(transaction.status).color;
    final statusText = TransactionStatus.fromValue(
      transaction.status,
    ).getLabel(isPostOwner: isPostOwner);
    final statusIcon = TransactionStatus.fromValue(transaction.status).icon;

    // Listen to transaction state changes
    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (next.failure == null && next.updatedTransaction != null) {
          // Success
          isEditing.value = false;
          transactionsNotifier.refresh();
          onTransactionUpdated?.call(next.updatedTransaction!);

          if (context.mounted) {
            context.showSuccessSnackBar('Cập nhật giao dịch thành công!');
          }
        } else if (next.failure != null) {
          // Error
          if (context.mounted) {
            context.showErrorSnackBar(next.failure!.message);
          }
        }
      }
    });

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
      selectedDeliveryMethod.value =
          transaction.method == DeliveryMethod.delivery.value
              ? DeliveryMethod.delivery
              : DeliveryMethod.meetInPerson;
    }

    Future<void> _handleRejectTransaction(
      BuildContext context,
      WidgetRef ref,
    ) async {
      try {
        await TransactionStatusHelpers.handleTransactionStatusUpdate(
          ref: ref,
          context: context,
          transaction: transaction,
          newStatus: 3, // Cancelled
          onTransactionUpdated: onTransactionUpdated,
        );
      } catch (e) {
        if (context.mounted) {
          context.showErrorDialog(
            title: 'Lỗi từ chối giao dịch',
            message: 'Không thể từ chối giao dịch: ${e.toString()}',
          );
        }
      }
    }

    // Thêm method xử lý hoàn tất với dialog
    Future<void> _handleCompleteTransaction(
      BuildContext context,
      WidgetRef ref,
    ) async {
      try {
        await TransactionStatusHelpers.handleTransactionStatusUpdate(
          ref: ref,
          context: context,
          transaction: transaction,
          newStatus: 2, // Success
          onTransactionUpdated: onTransactionUpdated,
        );
      } catch (e) {
        if (context.mounted) {
          context.showErrorDialog(
            title: 'Lỗi hoàn tất giao dịch',
            message: 'Không thể hoàn tất giao dịch: ${e.toString()}',
          );
        }
      }
    }

    Future<void> saveChanges(BuildContext context, WidgetRef ref) async {
      // Kiểm tra xem có thay đổi nào không
      bool hasChanges = false;

      // Kiểm tra thay đổi quantity
      for (final item in transaction.items) {
        final currentQuantity =
            editedItems.value[item.postItemID] ?? item.quantity;
        if (currentQuantity != item.quantity) {
          hasChanges = true;
          break;
        }
      }

      // Kiểm tra thay đổi delivery method
      final originalMethod =
          transaction.method == DeliveryMethod.delivery.value
              ? DeliveryMethod.delivery
              : DeliveryMethod.meetInPerson;
      if (selectedDeliveryMethod.value != originalMethod) {
        hasChanges = true;
      }

      // Nếu không có thay đổi, chỉ thoát edit mode
      if (!hasChanges) {
        context.showInfoDialog(
          title: 'Thông báo',
          content: 'Không có thay đổi nào để lưu.',
          icon: Icons.info_outline,
        );
        isEditing.value = false;
        return;
      }

      try {
        final updatedItems =
            transaction.items.map((item) {
              final newQuantity =
                  editedItems.value[item.postItemID] ?? item.quantity;
              return UpdateTransactionItemRequest(
                postItemID: item.postItemID,
                quantity: newQuantity,
                transactionID: transaction.id,
              );
            }).toList();

        final update = UpdateTransactionRequest(
          items: updatedItems,
          method: selectedDeliveryMethod.value.value,
          status: transaction.status,
        );

        await ref
            .read(transactionProvider.notifier)
            .updateTransaction(transaction.id, update);
      } catch (e) {
        if (context.mounted) {
          context.showErrorDialog(
            title: 'Lỗi lưu thay đổi',
            message: 'Không thể lưu thay đổi: ${e.toString()}',
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
            // Transaction items - Using EditableTransactionItem widget
            ...transaction.items.map((item) {
              final maxQuantity =
                  items
                      .firstWhere((i) => item.postItemID == i.id)
                      .currentQuantity;

              return Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
                child: EditableTransactionItem(
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

            // Delivery Method Selection - Using DeliveryMethodSelector widget
            if (isPostOwner && transaction.status == 1) ...[
              SizedBox(height: isTablet ? 16 : 12),
              DeliveryMethodSelector(
                selectedMethod: selectedDeliveryMethod.value,
                onMethodChanged: (method) {
                  selectedDeliveryMethod.value = method;
                },
                isEditing: isEditing.value,
                isLoading: transactionState.isLoading,
              ),
            ],

            TransactionActionButtons(
              transaction: transaction,
              isPostOwner: isPostOwner,
              index: index,
              isEditing: isEditing.value,
              isLoading: transactionState.isLoading,
              onEdit: () => isEditing.value = true,
              onCancel: cancelEditing,
              onSave: () => saveChanges(context, ref),
              onReject: () => _handleRejectTransaction(context, ref),
              onComplete: () => _handleCompleteTransaction(context, ref),
              onUndo:
                  () => TransactionStatusHelpers.showUndoConfirmationDialog(
                    context: context,
                    ref: ref,
                    transaction: transaction,
                    onTransactionUpdated: onTransactionUpdated,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
