import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/usecases/params/transaction_query.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/test/test.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/transaction_item_selection_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/transaction_list_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/models/interest_chat_transaction_data.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

class InterestChatScreen extends HookConsumerWidget {
  final String interestId;
  final InterestChatTransactionData? transactionData;

  const InterestChatScreen({
    super.key,
    required this.interestId,
    this.transactionData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final messageFocusNode = useFocusNode();

    final isLoading = useState(true);
    final isSending = useState(false);
    final chatInfo = useState<ChatInfo?>(null);
    final messages = useState<List<ChatMessage>>([]);

    final post = useState<InterestPost?>(null);
    final isPostOwner = useState<bool>(false);

    final displayName = useState<String>('');
    final displayAvatar = useState<String>('');

    // Watch transactions state
    final transactionsState = ref.watch(transactionsListProvider);
    final transactionsNotifier = ref.read(transactionsListProvider.notifier);

    // Initialize chat data and load transactions
    useEffect(() {
      Future.microtask(() async {
        // Initialize chat mock data
        chatInfo.value = mockChatInfo;
        messages.value = [...mockMessages];

        // Set post data from route params or use mock
        post.value = transactionData!.post;
        isPostOwner.value = transactionData!.isPostOwner;

        // Set display information
        displayName.value =
            isPostOwner.value
                ? post.value!.interests
                    .firstWhere((i) => i.id.toString() == interestId)
                    .userName
                : post.value!.authorName;
        displayAvatar.value =
            isPostOwner.value
                ? post.value!.interests
                    .firstWhere((i) => i.id.toString() == interestId)
                    .userAvatar
                : post.value!.authorAvatar;

        // Load transactions with default query
        final query = TransactionsQuery(
          sort: 'createdAt',
          order: 'DESC',
          postID: post.value?.id,
          searchBy: 'interestID',
          searchValue: interestId,
        );

        await transactionsNotifier.loadTransactions(
          newQuery: query,
          refresh: true,
        );

        isLoading.value = false;

        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(scrollController);
        });
      });
      return null;
    }, []);

    // Handle transaction state changes
    useEffect(() {
      if (transactionsState.failure != null) {
        // Show error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lỗi tải giao dịch: ${transactionsState.failure!.message}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
      return null;
    }, [transactionsState.failure]);

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
              transactions:
                  transactionsState.transactions, // Sử dụng từ provider
              isPostOwner: isPostOwner.value,
              items: post.value?.items ?? [],
              onTransactionUpdated: (updatedTransaction) {
                // Không cần gọi refresh ở đây nữa vì đã được handle trong bottom sheet
                // transactionsNotifier.refresh(); // Bỏ dòng này
              },
            ),
      );
    }

    void handleItemTransactionTap() {
      if (isPostOwner.value) return;

      final latestTransaction =
          transactionsState.transactions.isNotEmpty
              ? transactionsState.transactions.first
              : null;

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
              postItems: post.value?.items ?? [],
              interestId: int.parse(interestId),
              onTransactionSent: () {
                // Refresh transactions after creating new transaction
                transactionsNotifier.refresh();
              },
            ),
      );
    }

    void handleRefreshTransactions() {
      transactionsNotifier.refresh();
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
            if (chatInfo.value != null && post.value != null)
              _buildPostInfoHeader(
                isTablet,
                theme,
                colorScheme,
                transactionsState.transactions,
                post.value!,
                isPostOwner.value,
                transactionsState.isLoading,
                handlePostTap,
                handleTransactionTap,
                handleRefreshTransactions,
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
            _buildDisplayAvatar(displayAvatar, isTablet, colorScheme),

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

Widget _buildDisplayAvatar(
  String displayAvatar,
  bool isTablet,
  ColorScheme colorScheme,
) {
  final radius = isTablet ? 12.0 : 10.0;

  if (displayAvatar.isNotEmpty) {
    final imageBytes = Base64Utils.decodeImageFromBase64(displayAvatar);

    if (imageBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(imageBytes),
        child: null,
      );
    }
  }

  return CircleAvatar(
    radius: radius,
    backgroundColor: colorScheme.primaryContainer,
    child: Icon(
      Icons.person,
      size: isTablet ? 14 : 12,
      color: colorScheme.onPrimaryContainer,
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
  bool isLoadingTransactions,
  VoidCallback onPostTap,
  VoidCallback onTransactionTap,
  VoidCallback onRefreshTransactions,
) {
  // Get post type information
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
        SizedBox(height: isTablet ? 8 : 6),
        Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
          ),
          child: InkWell(
            onTap: isLoadingTransactions ? null : onTransactionTap,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (isLoadingTransactions)
                  SizedBox(
                    width: isTablet ? 20 : 18,
                    height: isTablet ? 20 : 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.secondary,
                    ),
                  )
                else if (latestTransaction != null)
                  Icon(
                    TransactionStatus.fromValue(
                      latestTransaction.status,
                    ).icon(),
                    size: isTablet ? 20 : 18,
                    color:
                        TransactionStatus.fromValue(
                          latestTransaction.status,
                        ).color(),
                  )
                else
                  Icon(
                    Icons.history,
                    size: isTablet ? 20 : 18,
                    color: theme.hintColor,
                  ),

                SizedBox(width: isTablet ? 12 : 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoadingTransactions
                            ? 'Đang tải giao dịch...'
                            : latestTransaction != null
                            ? 'Yêu cầu mới nhất'
                            : 'Chưa có giao dịch',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      if (latestTransaction != null) ...[
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
                    ],
                  ),
                ),

                // Refresh button
                if (!isLoadingTransactions)
                  IconButton(
                    onPressed: onRefreshTransactions,
                    icon: Icon(
                      Icons.refresh,
                      size: isTablet ? 18 : 16,
                      color: theme.hintColor,
                    ),
                    padding: EdgeInsets.all(isTablet ? 8 : 4),
                    constraints: BoxConstraints(
                      minWidth: isTablet ? 32 : 24,
                      minHeight: isTablet ? 32 : 24,
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
            _buildSenderAvatar(message.senderAvatar, isTablet, colorScheme)
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

Widget _buildSenderAvatar(
  String senderAvatar,
  bool isTablet,
  ColorScheme colorScheme,
) {
  final radius = isTablet ? 14.0 : 12.0;

  if (senderAvatar.isNotEmpty) {
    final imageBytes = Base64Utils.decodeImageFromBase64(senderAvatar);

    if (imageBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(imageBytes),
        child: null,
      );
    }
  }

  return CircleAvatar(
    radius: radius,
    backgroundColor: colorScheme.primary.withOpacity(0.1),
    child: Icon(
      Icons.person,
      size: isTablet ? 14 : 12,
      color: colorScheme.primary,
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
