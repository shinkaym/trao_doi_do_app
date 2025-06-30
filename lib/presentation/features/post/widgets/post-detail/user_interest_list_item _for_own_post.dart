import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/entities/message.dart';
import 'package:trao_doi_do_app/domain/usecases/params/message_query.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/user_avatar_for_list.dart';

class UserInterestListItemForOwnPost extends HookConsumerWidget {
  final PostInterest interest;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final int userID;

  const UserInterestListItemForOwnPost({
    super.key,
    required this.interest,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.userID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng provider riêng cho từng interest
    final transactionState = ref.watch(
      transactionByInterestProvider(interest.id),
    );
    final messagesState = ref.watch(messagesListProvider(interest.id));

    // Load data on mount
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Load transaction cho interest này
        ref
            .read(transactionByInterestProvider(interest.id).notifier)
            .loadTransaction();

        // Load messages
        ref
            .read(messagesListProvider(interest.id).notifier)
            .loadMessages(
              newQuery: MessagesQuery(
                interestID: interest.id,
                page: 1,
                limit: 1,
              ),
            );
      });
      return null;
    }, [interest.id]);

    // Show skeleton while loading
    if (transactionState.isLoading || messagesState.isLoading) {
      return _buildSkeletonItem();
    }

    // Helper functions
    String _buildItemsText(Transaction? transaction) {
      if (transaction == null || transaction.items.isEmpty) {
        return 'Chưa có món đồ';
      }

      final Map<String, int> itemCounts = {};
      for (final item in transaction.items) {
        final itemName = item.itemName.isNotEmpty ? item.itemName : 'Món đồ';
        itemCounts[itemName] = (itemCounts[itemName] ?? 0) + item.quantity;
      }

      final List<String> itemTexts = [];
      itemCounts.forEach((name, count) {
        itemTexts.add('$name: $count');
      });

      return itemTexts.join(', ');
    }

    TransactionStatus _getTransactionStatus(Transaction? transaction) {
      if (transaction == null) return TransactionStatus.unknown;
      return TransactionStatus.fromValue(transaction.status);
    }

    Message? _getLatestMessage() {
      if (messagesState.messages.isEmpty) return null;
      return messagesState.messages.last;
    }

    final transaction = transactionState.transaction;
    final transactionStatus = _getTransactionStatus(transaction);
    final itemsText = _buildItemsText(transaction);
    final latestMessage = _getLatestMessage();
    final hasUnreadMessage = latestMessage?.isRead == 0;

    // Kiểm tra lỗi riêng cho interest này
    final hasTransactionError =
        transactionState.failure != null && !transactionState.isLoading;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Main content section
            Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Column(
                children: [
                  // User info row
                  Row(
                    children: [
                      UserAvatarForList(
                        interest: interest,
                        isTablet: isTablet,
                        colorScheme: colorScheme,
                      ),
                      SizedBox(width: isTablet ? 12 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username
                            Text(
                              interest.userName,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),

                            // Latest message
                            if (latestMessage != null) ...[
                              SizedBox(height: isTablet ? 4 : 3),
                              _buildLatestMessage(
                                latestMessage,
                                hasUnreadMessage,
                              ),
                            ] else ...[
                              SizedBox(height: isTablet ? 2 : 1),
                              Text(
                                'Chưa có tin nhắn',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 11,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Transaction status badge - chỉ hiển thị nếu có transaction và không có lỗi
                      if (transaction != null && !hasTransactionError) ...[
                        SizedBox(width: isTablet ? 8 : 6),
                        _buildStatusBadge(transactionStatus),
                      ],

                      SizedBox(width: isTablet ? 8 : 6),

                      // Chat button
                      _buildChatButton(context, hasUnreadMessage),
                    ],
                  ),

                  // Items section - chỉ hiển thị nếu không có lỗi transaction cho interest này
                  if (!hasTransactionError) ...[
                    SizedBox(height: isTablet ? 12 : 10),
                    _buildItemsSection(itemsText, hasTransactionError),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(String itemsText, bool hasError) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 12 : 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 6 : 5),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: isTablet ? 16 : 14,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Món đồ trao đổi',
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            itemsText,
            style: TextStyle(
              fontSize: isTablet ? 12 : 11,
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Các widget methods khác giữ nguyên...
  Widget _buildSkeletonItem() {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            children: [
              // User info row skeleton
              Row(
                children: [
                  // Avatar skeleton
                  _buildSkeletonBox(
                    width: isTablet ? 48 : 40,
                    height: isTablet ? 48 : 40,
                    isCircle: true,
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username skeleton
                        _buildSkeletonBox(
                          width: 120,
                          height: isTablet ? 16 : 14,
                        ),
                        SizedBox(height: isTablet ? 6 : 4),
                        // Message skeleton
                        _buildSkeletonBox(
                          width: 200,
                          height: isTablet ? 12 : 11,
                        ),
                      ],
                    ),
                  ),

                  // Status badge skeleton
                  _buildSkeletonBox(
                    width: isTablet ? 80 : 70,
                    height: isTablet ? 28 : 24,
                    borderRadius: 20,
                  ),

                  SizedBox(width: isTablet ? 8 : 6),

                  // Chat button skeleton
                  _buildSkeletonBox(
                    width: isTablet ? 38 : 32,
                    height: isTablet ? 38 : 32,
                    borderRadius: 10,
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 12 : 10),

              // Items section skeleton
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Items header skeleton
                    Row(
                      children: [
                        _buildSkeletonBox(
                          width: isTablet ? 28 : 24,
                          height: isTablet ? 28 : 24,
                          borderRadius: 6,
                        ),
                        SizedBox(width: isTablet ? 8 : 6),
                        _buildSkeletonBox(
                          width: 100,
                          height: isTablet ? 13 : 12,
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    // Items text skeleton
                    _buildSkeletonBox(
                      width: double.infinity,
                      height: isTablet ? 12 : 11,
                    ),
                    SizedBox(height: isTablet ? 4 : 3),
                    _buildSkeletonBox(width: 150, height: isTablet ? 12 : 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    double? borderRadius,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius:
            isCircle ? null : BorderRadius.circular(borderRadius ?? 4),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: _buildShimmerEffect(),
    );
  }

  Widget _buildShimmerEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(value * 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
      onEnd: () {
        // Animation will repeat automatically due to TweenAnimationBuilder
      },
    );
  }

  Widget _buildLatestMessage(Message latestMessage, bool isUnread) {
    final isCurrentUserSender = latestMessage.senderID == userID;
    final messagePrefix = isCurrentUserSender ? 'Bạn: ' : '';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 6,
        vertical: isTablet ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color:
            isUnread
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isUnread ? Icons.mark_chat_unread : Icons.chat_bubble_outline,
            size: isTablet ? 14 : 12,
            color:
                isUnread
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(width: isTablet ? 6 : 4),
          Expanded(
            child: Text(
              '$messagePrefix${latestMessage.message}',
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                color:
                    isUnread
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 8,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: isTablet ? 14 : 12, color: status.color),
          SizedBox(width: isTablet ? 4 : 3),
          Text(
            status.getLabel(isPostOwner: true),
            style: TextStyle(
              fontSize: isTablet ? 11 : 10,
              fontWeight: FontWeight.w500,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton(BuildContext context, bool hasUnreadMessage) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.pushNamed(
                RouteNames.interestChat,
                pathParameters: {'interestId': interest.id.toString()},
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: isTablet ? 18 : 16,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),

        // Unread message badge
        if (hasUnreadMessage)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: isTablet ? 20 : 18,
              height: isTablet ? 20 : 18,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
              child: Center(
                child: Icon(
                  Icons.priority_high,
                  size: isTablet ? 12 : 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
