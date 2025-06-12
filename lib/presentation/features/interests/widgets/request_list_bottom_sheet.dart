import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/presentation/features/interests/screens/interest_chat_screen.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/request_item_detail_widget.dart';

class RequestListBottomSheet extends HookConsumerWidget {
  final List<ItemRequest> requests;
  final bool isPostOwner;
  final Function(ItemRequest)? onRequestUpdated;

  const RequestListBottomSheet({
    super.key,
    required this.requests,
    required this.isPostOwner,
    this.onRequestUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    // Sort requests by created date (newest first)
    final sortedRequests = [...requests]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
                    '${requests.length}',
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

          // Requests list
          if (requests.isEmpty)
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
                itemCount: sortedRequests.length,
                separatorBuilder:
                    (context, index) => SizedBox(height: isTablet ? 12 : 8),
                itemBuilder: (context, index) {
                  final request = sortedRequests[index];
                  return _buildRequestTile(
                    request,
                    theme,
                    colorScheme,
                    isTablet,
                    isPostOwner,
                    onRequestUpdated,
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

  Widget _buildRequestTile(
    ItemRequest request,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
    bool isPostOwner,
    Function(ItemRequest)? onRequestUpdated,
  ) {
    final statusColor = _getRequestStatusColor(request.status);
    final statusText = _getRequestStatusText(request.status, isPostOwner);
    final statusIcon = _getRequestStatusIcon(request.status, isPostOwner);

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
                      TimeUtils.formatTimeAgo(request.createdAt),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 14 : 13,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      '${request.items.length} món đồ',
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
            // Request items
            ...request.items.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
                child: RequestItemDetailWidget(
                  requestItem: item,
                  requestStatus: request.status,
                  isPostOwner: isPostOwner,
                  onQuantityUpdated: (newQuantity) {
                    // TODO: Handle quantity update
                    // This should update the item's approved quantity
                    // and call onRequestUpdated with the modified request
                  },
                  onConfirm: () {
                    // TODO: Handle confirm action
                    // This should accept/reject the request
                    // and call onRequestUpdated with the modified request
                  },
                ),
              );
            }).toList(),

            // Request actions (for post owner with pending requests)
            if (isPostOwner && request.status == 0) ...[
              SizedBox(height: isTablet ? 16 : 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Reject request
                        _handleRequestAction(request, 2, onRequestUpdated);
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
                        // TODO: Accept request
                        _handleRequestAction(request, 1, onRequestUpdated);
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

  void _handleRequestAction(
    ItemRequest request,
    int newStatus,
    Function(ItemRequest)? onRequestUpdated,
  ) {
    // TODO: Implement API call to update request status
    // For now, just simulate the update
    final updatedRequest = ItemRequest(
      id: request.id,
      userId: request.userId,
      postId: request.postId,
      items: request.items,
      status: newStatus,
      createdAt: request.createdAt,
      updatedAt: DateTime.now(),
    );

    onRequestUpdated?.call(updatedRequest);
  }
}

// Helper functions
IconData _getRequestStatusIcon(int status, bool isPostOwner) {
  if (status == 0) return Icons.pending;
  if (status == 1) return Icons.check_circle;
  if (status == 2) return Icons.cancel;
  return Icons.help;
}

Color _getRequestStatusColor(int status) {
  if (status == 0) return Colors.orange;
  if (status == 1) return Colors.green;
  if (status == 2) return Colors.red;
  return Colors.grey;
}

String _getRequestStatusText(int status, bool isPostOwner) {
  if (isPostOwner) {
    if (status == 0) return 'Chưa xử lý';
    if (status == 1) return 'Đã chấp nhận';
    if (status == 2) return 'Đã từ chối';
  } else {
    if (status == 0) return 'Đã gửi';
    if (status == 1) return 'Đã được chấp nhận';
    if (status == 2) return 'Đã bị từ chối';
  }
  return 'Không xác định';
}
