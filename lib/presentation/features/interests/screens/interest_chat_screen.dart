import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/test/test.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/transaction_item_selection_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/transaction_list_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

final List<Transaction> mockTransactions = [
  // Transaction(
  //   id: 101,
  //   interestID: 201,
  //   receiverID: 301,
  //   receiverName: 'Nguyễn Văn A',
  //   senderID: 401,
  //   senderName: 'Trần Thị B',
  //   status: 1,
  //   createdAt:
  //       DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
  //   updatedAt: null,
  //   items: [
  //     TransactionItem(
  //       itemID: 999,
  //       postItemID: 1,
  //       itemName: 'Bút bi',
  //       itemImage: 'https://example.com/pen.jpg',
  //       quantity: 2,
  //     ),
  //     TransactionItem(
  //       itemID: 999,
  //       postItemID: 2,
  //       itemName: 'Thước kẻ',
  //       itemImage: 'https://example.com/ruler.jpg',
  //       quantity: 1,
  //     ),
  //   ],
  // ),
  Transaction(
    id: 102,
    interestID: 202,
    receiverID: 302,
    receiverName: 'Lê Văn C',
    senderID: 402,
    senderName: 'Phạm Thị D',
    status: 2,
    createdAt:
        DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    items: [
      TransactionItem(
        itemID: 999,
        postItemID: 3,
        itemName: 'Sách toán',
        itemImage: 'https://example.com/mathbook.jpg',
        quantity: 1,
      ),
    ],
  ),
  Transaction(
    id: 103,
    interestID: 202,
    receiverID: 302,
    receiverName: 'Lê Văn C',
    senderID: 402,
    senderName: 'Phạm Thị D',
    status: 3,
    createdAt:
        DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    items: [
      TransactionItem(
        itemID: 999,
        postItemID: 3,
        itemName: 'Sách toán',
        itemImage: 'https://example.com/mathbook.jpg',
        quantity: 1,
      ),
    ],
  ),
];

final InterestPost mockInterestPost = InterestPost(
  id: 101,
  slug: 'tang-sach-cu-con-moi-855',
  title: 'Tặng bút, thước và sách toán',
  type: 1,
  description: 'Mình có một vài món đồ học tập muốn tặng lại cho các bạn cần.',
  updatedAt: DateTime.now().toIso8601String(),
  authorID: 999,
  authorName: 'Huấn Hoa Hồng',
  authorAvatar: '',
  interests: [
    Interest(
      id: 1,
      userID: 1,
      userName: "Super Admin",
      userAvatar: '',
      postID: 101,
      status: 1,
      createdAt: DateTime.now().toIso8601String(),
    ),
  ],
  items: [
    InterestItem(
      id: 1,
      itemID: 999,
      name: 'Bút bi',
      categoryName: 'Văn phòng phẩm',
      image: 'https://example.com/pen.jpg',
      quantity: 10,
      currentQuantity: 5,
    ),
    InterestItem(
      id: 2,
      itemID: 999,
      name: 'Thước kẻ',
      categoryName: 'Văn phòng phẩm',
      image: 'https://example.com/ruler.jpg',
      quantity: 5,
      currentQuantity: 2,
    ),
    InterestItem(
      id: 3,
      itemID: 999,
      name: 'Sách toán',
      categoryName: 'Sách',
      image: 'https://example.com/mathbook.jpg',
      quantity: 3,
      currentQuantity: 1,
    ),
  ],
);

class InterestChatScreen extends HookConsumerWidget {
  final String interestId;

  const InterestChatScreen({super.key, required this.interestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final messageFocusNode = useFocusNode();

    final isLoading = useState(true);
    final isSending = useState(false);
    final chatInfo = useState<ChatInfo?>(null);
    final messages = useState<List<ChatMessage>>([]);

    final transactions = useState<List<Transaction>>([]);
    final post = useState<InterestPost?>(null);
    final isPostOwner = useState<bool>(false);

    final displayName = useState<String>('');
    final displayAvatar = useState<String>('');

    // Initialize chat data
    useEffect(() {
      Future.microtask(() {
        chatInfo.value = mockChatInfo;
        messages.value = [...mockMessages];

        transactions.value = mockTransactions;
        post.value = mockInterestPost;
        if (post.value != null) {
          displayName.value =
              isPostOwner.value
                  ? post.value!.authorName
                  : post.value!.interests
                      .firstWhere((i) => i.id.toString() == interestId)
                      .userName;

          displayAvatar.value =
              isPostOwner.value
                  ? post.value!.authorAvatar
                  : post.value!.interests
                      .firstWhere((i) => i.id.toString() == interestId)
                      .userAvatar;
        }
        // isPostOwner.value = false;
        isLoading.value = false;

        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(scrollController);
        });
      });
      return null;
    }, []);

    void sendMessage() async {
      final messageText = messageController.text.trim();
      if (messageText.isEmpty || isSending.value) return;

      isSending.value = true;
      messageController.clear();

      // Add message to list
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'current_user',
        senderName: 'Bạn',
        senderAvatar: '',
        content: messageText,
        type: 'text',
        createdAt: DateTime.now(),
        isRead: false,
      );

      messages.value = [...messages.value, newMessage];

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(scrollController);
      });

      // Simulate sending delay
      await Future.delayed(const Duration(milliseconds: 500));
      isSending.value = false;

      // Simulate auto reply after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        final autoReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: chatInfo.value!.otherUserId,
          senderName: chatInfo.value!.otherUserName,
          senderAvatar: chatInfo.value!.otherUserAvatar,
          content: 'Cảm ơn bạn đã nhắn tin! Tôi sẽ phản hồi sớm nhất có thể.',
          type: 'text',
          createdAt: DateTime.now(),
          isRead: false,
        );

        messages.value = [...messages.value, autoReply];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(scrollController);
        });
      });
    }

    void handlePostTap() {
      if (post.value != null) {
        context.pushNamed(
          'post-detail',
          pathParameters: {'slug': post.value!.slug},
        );
      }
    }

    void handleTransactionTap() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => TransactionListBottomSheet(
              transactions: transactions.value,
              isPostOwner: isPostOwner.value,
              items: mockInterestPost.items,
              onTransactionUpdated: (updatedTransaction) {},
            ),
      );
    }

    void handleItemTransactionTap() {
      if (isPostOwner.value) return;
      final latestTransaction =
          transactions.value.isNotEmpty ? transactions.value.first : null;
      final canCreateTransaction =
          latestTransaction == null || latestTransaction.status != 1;
      if (!canCreateTransaction) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đợi yêu cầu mới nhất được phản hồi')),
        );
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => TransactionItemSelectionBottomSheet(
              postItems: mockInterestPost.items,
              interestId: interestId,
              onTransactionSent: () {
                // Optional: refresh transaction list
              },
            ),
      );
    }

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    if (isLoading.value) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: CustomAppBar(
          title: 'Trò chuyện',
          showBackButton: true,
          onBackPressed: () => context.pop(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(
        isTablet,
        theme,
        colorScheme,
        displayName.value,
        displayAvatar.value,
        isPostOwner.value,
        context,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Post info header
            if (chatInfo.value != null)
              _buildPostInfoHeader(
                isTablet,
                theme,
                colorScheme,
                transactions.value,
                post.value!,
                isPostOwner.value,
                handlePostTap,
                handleTransactionTap,
              ),

            // Messages list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 16 : 12,
                ),
                itemCount: messages.value.length,
                itemBuilder: (context, index) {
                  final message = messages.value[index];
                  final isCurrentUser = message.senderId == 'current_user';
                  final showAvatar =
                      index == 0 ||
                      messages.value[index - 1].senderId != message.senderId;

                  return _buildMessageBubble(
                    message,
                    isCurrentUser,
                    showAvatar,
                    isTablet,
                    theme,
                    colorScheme,
                    handlePostTap,
                  );
                },
              ),
            ),

            // Message input
            _buildMessageInput(
              isTablet,
              theme,
              colorScheme,
              messageController,
              messageFocusNode,
              isSending.value,
              isPostOwner.value,
              sendMessage,
              handleItemTransactionTap,
              context,
            ),
          ],
        ),
      ),
    );
  }
}

void _scrollToBottom(ScrollController scrollController) {
  if (scrollController.hasClients) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

PreferredSizeWidget _buildAppBar(
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  String displayName,
  String displayAvatar,
  bool isPostOwner,
  BuildContext context,
) {
  return AppBar(
    backgroundColor: colorScheme.surface,
    elevation: 0,
    leading: IconButton(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back),
    ),
    title: InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: isTablet ? 20 : 18,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child:
                  displayAvatar.isNotEmpty
                      ? ClipOval(
                        child: Image.network(
                          displayAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: isTablet ? 20 : 18,
                              color: colorScheme.primary,
                            );
                          },
                        ),
                      )
                      : Icon(
                        Icons.person,
                        size: isTablet ? 20 : 18,
                        color: colorScheme.primary,
                      ),
            ),

            SizedBox(width: isTablet ? 12 : 8),

            // User info
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: colorScheme.outline.withOpacity(0.2)),
    ),
  );
}

Widget _buildPostInfoHeader(
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  List<Transaction> transactions,
  InterestPost post,
  bool isPostOwner,
  VoidCallback onPostTap,
  VoidCallback onTransactionTap,
) {
  // Sử dụng enum để lấy thông tin post type
  final postTypeEnum = CreatePostType.fromValue(post.type);
  final latestTransaction = transactions.isNotEmpty ? transactions.first : null;

  return Container(
    margin: EdgeInsets.all(isTablet ? 16 : 12),
    child: Column(
      children: [
        // Post info
        Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          ),
          child: InkWell(
            onTap: onPostTap,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Icon(
                  postTypeEnum.icon(),
                  size: isTablet ? 24 : 20,
                  color: postTypeEnum.color(),
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Về bài đăng: ${postTypeEnum.label()}',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        post.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 14 : 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: isTablet ? 16 : 14,
                  color: theme.hintColor,
                ),
              ],
            ),
          ),
        ),

        // Latest transaction info
        if (latestTransaction != null) ...[
          SizedBox(height: isTablet ? 8 : 6),
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
            ),
            child: InkWell(
              onTap: onTransactionTap,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Icon(
                    TransactionStatus.fromValue(
                      latestTransaction.status,
                    ).icon(),
                    size: isTablet ? 20 : 18,
                    color:
                        TransactionStatus.fromValue(
                          latestTransaction.status,
                        ).color(),
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yêu cầu mới nhất',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: theme.hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isTablet ? 4 : 2),
                        Row(
                          children: [
                            Text(
                              TimeUtils.formatTimeAgo(
                                DateTime.parse(latestTransaction.createdAt),
                              ),

                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: isTablet ? 13 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 8 : 6,
                                vertical: isTablet ? 4 : 2,
                              ),
                              decoration: BoxDecoration(
                                color: TransactionStatus.fromValue(
                                  latestTransaction.status,
                                ).color().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                TransactionStatus.fromValue(
                                  latestTransaction.status,
                                ).label(isPostOwner: isPostOwner),
                                style: TextStyle(
                                  fontSize: isTablet ? 11 : 10,
                                  color:
                                      TransactionStatus.fromValue(
                                        latestTransaction.status,
                                      ).color(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isTablet ? 16 : 14,
                    color: theme.hintColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildMessageBubble(
  ChatMessage message,
  bool isCurrentUser,
  bool showAvatar,
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  VoidCallback onPostTap,
) {
  return Container(
    margin: EdgeInsets.only(
      bottom: isTablet ? 8 : 6,
      left: isCurrentUser ? (isTablet ? 60 : 40) : 0,
      right: isCurrentUser ? 0 : (isTablet ? 60 : 40),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // Avatar for received messages
        if (!isCurrentUser) ...[
          if (showAvatar)
            CircleAvatar(
              radius: isTablet ? 14 : 12,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child:
                  message.senderAvatar.isNotEmpty
                      ? ClipOval(
                        child: Image.network(
                          message.senderAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: isTablet ? 14 : 12,
                              color: colorScheme.primary,
                            );
                          },
                        ),
                      )
                      : Icon(
                        Icons.person,
                        size: isTablet ? 14 : 12,
                        color: colorScheme.primary,
                      ),
            )
          else
            SizedBox(width: isTablet ? 28 : 24),

          SizedBox(width: isTablet ? 8 : 6),
        ],

        // Message content
        Flexible(
          child: Column(
            crossAxisAlignment:
                isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            children: [
              // Message bubble
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isCurrentUser
                          ? colorScheme.primary
                          : colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                    bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                  ),
                ),
                child: _buildTextMessage(
                  message,
                  isTablet,
                  theme,
                  colorScheme,
                  isCurrentUser,
                ),
              ),

              SizedBox(height: isTablet ? 4 : 2),

              // Time and read status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TimeUtils.formatTimeAgo(message.createdAt),
                    style: TextStyle(
                      fontSize: isTablet ? 11 : 10,
                      color: theme.hintColor,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    SizedBox(width: isTablet ? 4 : 2),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: isTablet ? 14 : 12,
                      color: message.isRead ? Colors.blue : theme.hintColor,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTextMessage(
  ChatMessage message,
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  bool isCurrentUser,
) {
  return Text(
    message.content,
    style: TextStyle(
      fontSize: isTablet ? 15 : 14,
      color:
          isCurrentUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      height: 1.4,
    ),
  );
}

Widget _buildMessageInput(
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  TextEditingController messageController,
  FocusNode messageFocusNode,
  bool isSending,
  bool isPostOwner,
  VoidCallback onSend,
  VoidCallback onItemTransaction,
  BuildContext context,
) {
  return Container(
    padding: EdgeInsets.all(isTablet ? 16 : 12),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      border: Border(
        top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
    ),
    child: SafeArea(
      child: Row(
        children: [
          // Transaction button (only for non-post-owner)
          if (!isPostOwner)
            IconButton(
              onPressed: onItemTransaction,
              icon: const Icon(Icons.shopping_cart),
              style: IconButton.styleFrom(foregroundColor: colorScheme.primary),
            ),

          SizedBox(width: isTablet ? 8 : 4),

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: TextField(
                controller: messageController,
                focusNode: messageFocusNode,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 12 : 8,
                  ),
                ),
                style: TextStyle(fontSize: isTablet ? 15 : 14),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                enabled: !isSending,
              ),
            ),
          ),

          SizedBox(width: isTablet ? 8 : 4),

          // Send button
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isSending ? null : onSend,
              icon:
                  isSending
                      ? SizedBox(
                        width: isTablet ? 20 : 16,
                        height: isTablet ? 20 : 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                      : const Icon(Icons.send),
              style: IconButton.styleFrom(
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
