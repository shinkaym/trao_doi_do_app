import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';

class ClaimRequestsBottomSheet extends ConsumerStatefulWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final OldStockItem? Function(int) getItemById;
  final VoidCallback onUpdated;

  const ClaimRequestsBottomSheet({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.getItemById,
    required this.onUpdated,
  });

  @override
  ConsumerState<ClaimRequestsBottomSheet> createState() =>
      _ClaimRequestsBottomSheetState();
}

class _ClaimRequestsBottomSheetState
    extends ConsumerState<ClaimRequestsBottomSheet> {
  late Map<int, int> _localClaimRequests = {};
  late Map<int, int> _originalClaimRequests = {};

  final Set<int> _deletedItems = {};
  bool _isUpdating = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _initializeData();
        _loadClaimRequests();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isUpdating = false;
    super.dispose();
  }

  // Safe setState wrapper
  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  void _initializeData() {
    if (_isDisposed || !mounted) return;

    try {
      final claimRequestsState = ref.read(claimRequestsListProvider);
      if (!claimRequestsState.isLoading) {
        _localClaimRequests = Map.fromEntries(
          claimRequestsState.claimRequests.map(
            (item) => MapEntry(item.itemID, item.quantity),
          ),
        );
        _originalClaimRequests = Map.from(_localClaimRequests);
      }
    } catch (e) {
      _localClaimRequests = {};
      _originalClaimRequests = {};
    }
  }

  int _getAvailableForClaim(OldStockItem item) {
    return item.quantity < item.maxClaim ? item.quantity : item.maxClaim;
  }

  Future<void> _loadClaimRequests() async {
    if (_isDisposed || !mounted) return;

    try {
      final notifier = ref.read(claimRequestsListProvider.notifier);
      await notifier.loadClaimRequests();

      if (!_isDisposed && mounted) {
        _safeSetState(() {
          _initializeData();
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        if (!e.toString().contains('dispose') &&
            !e.toString().contains('Tried to use')) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && !_isDisposed) {
              context.showErrorSnackBar('Không thể tải danh sách yêu cầu: $e');
            }
          });
        }
      }
    }
  }

  void _updateItemQuantity(int itemID, int newQuantity) {
    if (_isDisposed || !mounted) return;

    _safeSetState(() {
      if (newQuantity <= 0) {
        _localClaimRequests.remove(itemID);
        _deletedItems.add(itemID);
      } else {
        final item = widget.getItemById(itemID);
        if (item != null) {
          final availableForClaim = _getAvailableForClaim(item);

          if (newQuantity > availableForClaim) {
            // Xác định lý do giới hạn
            String reason =
                item.quantity < item.maxClaim ? 'quantity' : 'maxClaim';
            String message;
            if (reason == 'maxClaim') {
              message =
                  'Chỉ được phép nhận tối đa $availableForClaim "${item.itemName}"';
            } else {
              message =
                  'Chỉ còn $availableForClaim "${item.itemName}" trong kho';
            }

            // Schedule the snackbar for the next frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_isDisposed && mounted) {
                context.showErrorSnackBar(message);
              }
            });
            return;
          }
        }
        _localClaimRequests[itemID] = newQuantity;
      }
    });
  }

  Future<void> _handleUpdate() async {
    if (_isDisposed || !mounted || _isUpdating) return;

    _safeSetState(() {
      _isUpdating = true;
    });

    try {
      // Check if providers are still available
      if (_isDisposed || !mounted) return;

      final claimRequestNotifier = ref.read(claimRequestProvider.notifier);
      final claimRequestsListNotifier = ref.read(
        claimRequestsListProvider.notifier,
      );

      // Process deleted items
      for (final itemID in _deletedItems) {
        if (_isDisposed || !mounted) return;
        await claimRequestNotifier.deleteClaimRequest(itemID);
        if (!_isDisposed && mounted) {
          claimRequestsListNotifier.removeClaimRequest(itemID);
        }
      }

      // Process updated quantities
      for (final entry in _localClaimRequests.entries) {
        if (_isDisposed || !mounted) return;

        final itemID = entry.key;
        final newQuantity = entry.value;
        final originalQuantity = _originalClaimRequests[itemID];

        if (originalQuantity != newQuantity) {
          await claimRequestNotifier.updateClaimRequest(itemID, newQuantity);
          if (!_isDisposed && mounted) {
            claimRequestsListNotifier.updateClaimRequestQuantity(
              itemID,
              newQuantity,
            );
          }
        }
      }

      // Delete all if empty
      if (_localClaimRequests.isEmpty && !_isDisposed && mounted) {
        await claimRequestNotifier.deleteAllClaimRequests();
      }

      if (!_isDisposed && mounted) {
        Navigator.pop(context);
        widget.onUpdated();

        // Schedule success message for after navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && mounted) {
            context.showSuccessSnackBar('Cập nhật thành công!');
          }
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        _safeSetState(() {
          _isUpdating = false;
        });

        // Only show error if it's not a disposal-related error
        if (!e.toString().contains('dispose') &&
            !e.toString().contains('Tried to use')) {
          // Schedule error message for the next frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed && mounted) {
              context.showErrorSnackBar('Có lỗi xảy ra: ${e.toString()}');
            }
          });
        }
      }
    }
  }

  bool get _hasChanges {
    if (_deletedItems.isNotEmpty) return true;

    for (final entry in _localClaimRequests.entries) {
      final itemID = entry.key;
      final newQuantity = entry.value;
      final originalQuantity = _originalClaimRequests[itemID];

      if (originalQuantity != newQuantity) return true;
    }

    return false;
  }

  // Helper method to check if we should show update button
  bool get _shouldShowUpdateButton {
    // Show update button if there are changes OR if we originally had items but now have none
    return _hasChanges ||
        (_originalClaimRequests.isNotEmpty && _localClaimRequests.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if disposed
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8;

    // Safe provider access with fallback
    late final claimRequestState;
    late final claimRequestsListState;

    try {
      claimRequestState = ref.watch(claimRequestProvider);
      claimRequestsListState = ref.read(claimRequestsListProvider);
    } catch (e) {
      // If providers are disposed, return a minimal widget
      return Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: widget.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Center(child: Text('Widget đã bị đóng')),
      );
    }

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
                  Icons.list_alt_outlined,
                  color: widget.colorScheme.primary,
                  size: widget.isTablet ? 28 : 24,
                ),
                SizedBox(width: widget.isTablet ? 16 : 12),
                Expanded(
                  child: Text(
                    'Danh sách món đồ đã yêu cầu',
                    style: widget.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isTablet ? 22 : 18,
                    ),
                  ),
                ),
                if (claimRequestsListState.isLoading)
                  SizedBox(
                    width: widget.isTablet ? 24 : 20,
                    height: widget.isTablet ? 24 : 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.colorScheme.primary,
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: _isDisposed ? null : _loadClaimRequests,
                    icon: Icon(
                      Icons.refresh,
                      color: widget.colorScheme.primary,
                      size: widget.isTablet ? 28 : 24,
                    ),
                  ),
                IconButton(
                  onPressed:
                      (_isUpdating ||
                              claimRequestState.isSubmitting ||
                              _isDisposed)
                          ? null
                          : () {
                            if (mounted && !_isDisposed) {
                              Navigator.pop(context);
                            }
                          },
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
          if (claimRequestsListState.isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.colorScheme.primary,
                  ),
                ),
              ),
            )
          else if (_localClaimRequests.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt_outlined,
                      size: widget.isTablet ? 80 : 64,
                      color: widget.colorScheme.outline.withOpacity(0.3),
                    ),
                    SizedBox(height: widget.isTablet ? 24 : 16),
                    Text(
                      _originalClaimRequests.isNotEmpty
                          ? 'Tất cả yêu cầu đã được xóa'
                          : 'Không có yêu cầu nào',
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        color: widget.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: widget.isTablet ? 18 : 16,
                      ),
                    ),
                    if (_originalClaimRequests.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: widget.isTablet ? 12 : 8),
                        child: Text(
                          'Nhấn "Cập nhật" để lưu thay đổi',
                          style: widget.theme.textTheme.bodyMedium?.copyWith(
                            color: widget.colorScheme.primary,
                            fontSize: widget.isTablet ? 14 : 12,
                          ),
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
                itemCount: _localClaimRequests.length,
                itemBuilder: (context, index) {
                  final entry = _localClaimRequests.entries.elementAt(index);
                  final itemID = entry.key;
                  final quantity = entry.value;

                  final claimRequestItem = claimRequestsListState.claimRequests
                      .firstWhere((item) => item.itemID == itemID);
                  final item = widget.getItemById(itemID);
                  final availableForClaim =
                      item != null ? _getAvailableForClaim(item) : 0;
                  final originalQuantity = _originalClaimRequests[itemID] ?? 0;
                  final hasChanged = quantity != originalQuantity;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.only(bottom: widget.isTablet ? 16 : 12),
                    padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      color: widget.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            hasChanged
                                ? widget.colorScheme.primary.withOpacity(0.5)
                                : widget.colorScheme.outline.withOpacity(0.2),
                        width: hasChanged ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Item Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildItemImage(
                                claimRequestItem.itemImage,
                              ),
                            ),
                            SizedBox(width: widget.isTablet ? 16 : 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    claimRequestItem.itemName,
                                    style: widget.theme.textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: widget.isTablet ? 16 : 14,
                                        ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    claimRequestItem.categoryName,
                                    style: widget.theme.textTheme.bodySmall
                                        ?.copyWith(
                                          color: widget.colorScheme.onSurface
                                              .withOpacity(0.6),
                                          fontSize: widget.isTablet ? 13 : 11,
                                        ),
                                  ),
                                  if (item != null)
                                    Text(
                                      'Còn lại: ${item.quantity} | Tối đa: ${item.maxClaim}',
                                      style: widget.theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                availableForClaim > 0
                                                    ? widget.colorScheme.primary
                                                    : widget.colorScheme.error,
                                            fontSize: widget.isTablet ? 12 : 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: widget.isTablet ? 16 : 12),

                        // Quantity Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (hasChanged)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: widget.isTablet ? 12 : 8,
                                  vertical: widget.isTablet ? 4 : 3,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Đã thay đổi',
                                  style: widget.theme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: widget.colorScheme.primary,
                                        fontSize: widget.isTablet ? 11 : 9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              )
                            else
                              SizedBox.shrink(),

                            Row(
                              children: [
                                IconButton(
                                  onPressed:
                                      (_isUpdating ||
                                              claimRequestState.isSubmitting ||
                                              _isDisposed)
                                          ? null
                                          : () => _updateItemQuantity(
                                            itemID,
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
                                      (_isUpdating ||
                                              claimRequestState.isSubmitting ||
                                              _isDisposed)
                                          ? null
                                          : () {
                                            if (item != null) {
                                              final availableForClaim =
                                                  _getAvailableForClaim(item);
                                              if (quantity >=
                                                  availableForClaim) {
                                                String reason =
                                                    item.quantity <
                                                            item.maxClaim
                                                        ? 'quantity'
                                                        : 'maxClaim';
                                                String message;
                                                if (reason == 'maxClaim') {
                                                  message =
                                                      'Chỉ được phép nhận tối đa $availableForClaim "${claimRequestItem.itemName}"';
                                                } else {
                                                  message =
                                                      'Chỉ còn $availableForClaim "${claimRequestItem.itemName}" trong kho';
                                                }

                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      if (!_isDisposed &&
                                                          mounted) {
                                                        context
                                                            .showErrorSnackBar(
                                                              message,
                                                            );
                                                      }
                                                    });
                                                return;
                                              }
                                            }
                                            _updateItemQuantity(
                                              itemID,
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
                                                  quantity >=
                                                      _getAvailableForClaim(
                                                        item,
                                                      ))
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
                                                  quantity >=
                                                      _getAvailableForClaim(
                                                        item,
                                                      ))
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
                        if (item != null &&
                            quantity > _getAvailableForClaim(item))
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
                                    'Số lượng vượt quá hàng có sẵn',
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

          // Bottom Actions - Updated condition
          if (_shouldShowUpdateButton)
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
                      (!_hasChanges ||
                              _isUpdating ||
                              claimRequestState.isSubmitting ||
                              _isDisposed)
                          ? null
                          : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _hasChanges
                            ? widget.colorScheme.primary
                            : widget.colorScheme.outline.withOpacity(0.3),
                    foregroundColor:
                        _hasChanges
                            ? widget.colorScheme.onPrimary
                            : widget.colorScheme.onSurface.withOpacity(0.6),
                    padding: EdgeInsets.symmetric(
                      vertical: widget.isTablet ? 16 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _hasChanges ? 2 : 0,
                  ),
                  child:
                      (_isUpdating || claimRequestState.isSubmitting)
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
                                'Đang cập nhật...',
                                style: TextStyle(
                                  fontSize: widget.isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            _hasChanges ? 'Cập nhật' : 'Không có thay đổi',
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

  Widget _buildItemImage(String base64Image) {
    if (base64Image.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(base64Image);

      if (imageBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageBytes,
            width: widget.isTablet ? 60 : 48,
            height: widget.isTablet ? 60 : 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: widget.isTablet ? 60 : 48,
                height: widget.isTablet ? 60 : 48,
                decoration: BoxDecoration(
                  color: widget.colorScheme.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.broken_image_outlined,
                  color: widget.colorScheme.outline,
                  size: widget.isTablet ? 24 : 20,
                ),
              );
            },
          ),
        );
      }
    }

    // Fallback for empty or invalid base64
    return Container(
      width: widget.isTablet ? 60 : 48,
      height: widget.isTablet ? 60 : 48,
      decoration: BoxDecoration(
        color: widget.colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_outlined,
        color: widget.colorScheme.outline,
        size: widget.isTablet ? 24 : 20,
      ),
    );
  }
}
