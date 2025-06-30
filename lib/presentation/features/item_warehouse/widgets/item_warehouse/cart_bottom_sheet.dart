import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/snackbar_extensions.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';
import 'package:trao_doi_do_app/domain/entities/request/item_warehouse_request.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  final Map<String, int> selectedItems;
  final Function(String, int) onUpdateQuantity;
  final VoidCallback onConfirm;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final OldStockItem? Function(int) getItemById;

  const CartBottomSheet({
    super.key,
    required this.selectedItems,
    required this.onUpdateQuantity,
    required this.onConfirm,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.getItemById,
  });

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  late Map<String, int> _localSelectedItems;

  @override
  void initState() {
    super.initState();
    _localSelectedItems = Map<String, int>.from(widget.selectedItems);
  }

  // Helper function để tính số lượng có thể nhận
  int getAvailableForClaim(OldStockItem item) {
    return item.quantity < item.maxClaim ? item.quantity : item.maxClaim;
  }

  void _updateItemQuantity(String itemKey, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _localSelectedItems.remove(itemKey);
      } else {
        final itemIdStr = itemKey.split('_').first;
        final itemId = int.tryParse(itemIdStr);

        if (itemId != null) {
          final item = widget.getItemById(itemId);
          if (item != null) {
            final availableForClaim = getAvailableForClaim(item);
            
            if (newQuantity > availableForClaim) {
              final itemName = itemKey.split('_').skip(1).join('_');
              
              // Xác định thông báo lỗi phù hợp
              String errorMessage;
              if (item.quantity < item.maxClaim) {
                errorMessage = 'Chỉ còn ${item.quantity} "$itemName" trong kho';
              } else {
                errorMessage = 'Chỉ được phép nhận tối đa ${item.maxClaim} "$itemName"';
              }
              
              context.showErrorSnackBar(errorMessage);
              return;
            }
          }
        }

        _localSelectedItems[itemKey] = newQuantity;
      }
    });

    widget.onUpdateQuantity(itemKey, newQuantity);
  }

  Future<void> _handleConfirm() async {
    // Kiểm tra validation trước khi tạo claim request
    bool hasInvalidQuantity = false;
    List<String> invalidItems = [];

    for (final entry in _localSelectedItems.entries) {
      final itemKey = entry.key;
      final quantity = entry.value;
      final itemIdStr = itemKey.split('_').first;
      final itemId = int.tryParse(itemIdStr);

      if (itemId != null) {
        final item = widget.getItemById(itemId);
        if (item != null) {
          final availableForClaim = getAvailableForClaim(item);
          
          if (quantity > availableForClaim) {
            hasInvalidQuantity = true;
            final itemName = itemKey.split('_').skip(1).join('_');
            invalidItems.add(itemName);
          }
        }
      }
    }

    if (hasInvalidQuantity) {
      context.showErrorSnackBar(
        'Vui lòng điều chỉnh số lượng theo hàng có sẵn: ${invalidItems.join(', ')}',
      );
      return;
    }

    // Chuyển đổi selectedItems thành List<ClaimItemRequest>
    final List<ClaimItemRequest> claimItems = [];

    for (final entry in _localSelectedItems.entries) {
      final itemKey = entry.key;
      final quantity = entry.value;
      final itemIdStr = itemKey.split('_').first;
      final itemId = int.tryParse(itemIdStr);

      if (itemId != null) {
        claimItems.add(ClaimItemRequest(itemID: itemId, quantity: quantity));
      }
    }

    if (claimItems.isEmpty) {
      context.showErrorSnackBar('Không có món đồ nào để tạo yêu cầu');
      return;
    }

    // Gọi provider để tạo claim request
    try {
      // Cập nhật claim items trong provider
      final claimNotifier = ref.read(claimRequestProvider.notifier);

      // Clear existing items và add new items
      claimNotifier.clearClaimItems();
      for (final claimItem in claimItems) {
        claimNotifier.addClaimItem(claimItem.itemID, claimItem.quantity);
      }

      // Tạo claim request
      await claimNotifier.createClaimRequest();

      // Đóng bottom sheet và gọi callback
      if (mounted) {
        Navigator.pop(context);
        widget.onConfirm();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          'Có lỗi xảy ra khi tạo yêu cầu: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8;
    final claimRequestState = ref.watch(claimRequestProvider);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: widget.colorScheme.primary,
                  size: widget.isTablet ? 28 : 24,
                ),
                SizedBox(width: widget.isTablet ? 16 : 12),
                Expanded(
                  child: Text(
                    'Giỏ đồ',
                    style: widget.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isTablet ? 22 : 18,
                    ),
                  ),
                ),
                IconButton(
                  onPressed:
                      claimRequestState.isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: widget.colorScheme.onSurface.withOpacity(0.6),
                    size: widget.isTablet ? 28 : 24,
                  ),
                ),
              ],
            ),
          ),

          // Items List
          if (_localSelectedItems.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: widget.isTablet ? 80 : 64,
                      color: widget.colorScheme.outline.withOpacity(0.3),
                    ),
                    SizedBox(height: widget.isTablet ? 24 : 16),
                    Text(
                      'Danh sách trống',
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        color: widget.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: widget.isTablet ? 18 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isTablet ? 24 : 16,
                  vertical: widget.isTablet ? 16 : 8,
                ),
                itemCount: _localSelectedItems.length,
                itemBuilder: (context, index) {
                  final entry = _localSelectedItems.entries.elementAt(index);
                  final itemKey = entry.key;
                  final quantity = entry.value;
                  final itemIdStr = itemKey.split('_').first;
                  final itemId = int.tryParse(itemIdStr);
                  final itemName = itemKey.split('_').skip(1).join('_');

                  final item =
                      itemId != null ? widget.getItemById(itemId) : null;
                  final availableForClaim = item != null ? getAvailableForClaim(item) : 0;
                  
                  // Xác định loại giới hạn để hiển thị thông tin phù hợp
                  String limitInfo = '';
                  if (item != null) {
                    if (item.quantity < item.maxClaim) {
                      limitInfo = 'Còn lại: ${item.quantity} (trong kho)';
                    } else {
                      limitInfo = 'Tối đa: ${item.maxClaim} (quy định)';
                    }
                  }

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.only(bottom: widget.isTablet ? 16 : 12),
                    padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      color: widget.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemName,
                                    style: widget.theme.textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: widget.isTablet ? 16 : 14,
                                        ),
                                  ),
                                  if (item != null)
                                    Text(
                                      limitInfo,
                                      style: widget.theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: widget.colorScheme.onSurface
                                                .withOpacity(0.6),
                                            fontSize: widget.isTablet ? 13 : 11,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed:
                                      claimRequestState.isSubmitting
                                          ? null
                                          : () => _updateItemQuantity(
                                            itemKey,
                                            quantity - 1,
                                          ),
                                  icon: Container(
                                    padding: EdgeInsets.all(
                                      widget.isTablet ? 8 : 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.colorScheme.error
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      quantity == 1
                                          ? Icons.delete_outline
                                          : Icons.remove,
                                      color: widget.colorScheme.error,
                                      size: widget.isTablet ? 20 : 16,
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: widget.isTablet ? 16 : 12,
                                    vertical: widget.isTablet ? 8 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: widget.theme.textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              widget
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                          fontSize: widget.isTablet ? 16 : 14,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      claimRequestState.isSubmitting
                                          ? null
                                          : () {
                                            if (item != null &&
                                                quantity >= availableForClaim) {
                                              String errorMessage;
                                              if (item.quantity < item.maxClaim) {
                                                errorMessage = 'Chỉ còn ${item.quantity} "$itemName" trong kho';
                                              } else {
                                                errorMessage = 'Chỉ được phép nhận tối đa ${item.maxClaim} "$itemName"';
                                              }
                                              context.showErrorSnackBar(errorMessage);
                                              return;
                                            }
                                            _updateItemQuantity(
                                              itemKey,
                                              quantity + 1,
                                            );
                                          },
                                  icon: Container(
                                    padding: EdgeInsets.all(
                                      widget.isTablet ? 8 : 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (item != null &&
                                                  quantity >= availableForClaim)
                                              ? widget.colorScheme.outline
                                                  .withOpacity(0.3)
                                              : widget.colorScheme.primary
                                                  .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color:
                                          (item != null &&
                                                  quantity >= availableForClaim)
                                              ? widget.colorScheme.outline
                                              : widget.colorScheme.primary,
                                      size: widget.isTablet ? 20 : 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Warning for exceeded quantity
                        if (item != null && quantity > availableForClaim)
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.only(top: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.isTablet ? 12 : 8,
                              vertical: widget.isTablet ? 8 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: widget.colorScheme.onErrorContainer,
                                  size: widget.isTablet ? 16 : 14,
                                ),
                                SizedBox(width: widget.isTablet ? 8 : 6),
                                Expanded(
                                  child: Text(
                                    item.quantity < item.maxClaim 
                                        ? 'Số lượng vượt quá hàng có sẵn trong kho'
                                        : 'Số lượng vượt quá giới hạn cho phép nhận',
                                    style: widget.theme.textTheme.bodySmall
                                        ?.copyWith(
                                          color:
                                              widget
                                                  .colorScheme
                                                  .onErrorContainer,
                                          fontSize: widget.isTablet ? 12 : 10,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Bottom Actions
          if (_localSelectedItems.isNotEmpty)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: widget.colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      claimRequestState.isSubmitting ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorScheme.primary,
                    foregroundColor: widget.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      vertical: widget.isTablet ? 16 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      claimRequestState.isSubmitting
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: widget.isTablet ? 20 : 16,
                                height: widget.isTablet ? 20 : 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: widget.isTablet ? 12 : 8),
                              Text(
                                'Đang xử lý...',
                                style: TextStyle(
                                  fontSize: widget.isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            'Xác nhận (${_localSelectedItems.values.fold(0, (sum, qty) => sum + qty)} món đồ)',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}