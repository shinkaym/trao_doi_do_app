import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/message.dart';
import 'package:trao_doi_do_app/domain/usecases/params/transaction_query.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/chat_app_bar.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/post_info_header.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/transaction_item_selection_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/transaction_list_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/models/interest_chat_transaction_data.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';

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
    ref.watch(webSocketConnectionProvider);

    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final messageFocusNode = useFocusNode();

    final isLoading = useState(true);
    final isSending = useState(false);

    final post = useState<InterestPost?>(null);
    final isPostOwner = useState<bool>(false);
    final displayName = useState<String>('');
    final displayAvatar = useState<String>('');
    final displayUserId = useState<int?>(null);

    // Watch providers
    final authState = ref.watch(authProvider);
    final messagesState = ref.watch(
      messagesListProvider(int.parse(interestId)),
    );
    final messagesNotifier = ref.read(
      messagesListProvider(int.parse(interestId)).notifier,
    );
    final transactionsState = ref.watch(transactionsListProvider);
    final transactionsNotifier = ref.read(transactionsListProvider.notifier);

    // WebSocket providers
    final webSocketState = ref.watch(webSocketProvider);
    final webSocketNotifier = ref.read(webSocketProvider.notifier);

    // Initialize chat data and load messages/transactions
    useEffect(() {
      Future.microtask(() async {
        if (transactionData != null && authState.user != null) {
          // Set post data from route params
          post.value = transactionData!.post;
          isPostOwner.value = transactionData!.isPostOwner;

          // Set display information based on user role
          if (isPostOwner.value) {
            // Post owner sees the interested user's info
            final interestedUser = post.value!.interests.firstWhere(
              (i) => i.id.toString() == interestId,
            );
            displayName.value = interestedUser.userName;
            displayAvatar.value = interestedUser.userAvatar;
            displayUserId.value = interestedUser.userID;
          } else {
            // Interested user sees the post author's info
            displayName.value = post.value!.authorName;
            displayAvatar.value = post.value!.authorAvatar;
            displayUserId.value = post.value!.authorID;
          }

          // Connect to WebSocket if not already connected
          // if (!webSocketState.isConnected && !webSocketState.isConnecting) {
          //   await webSocketNotifier.connectToChat(authState.user?.token);
          // }

          // Join the chat room
          if (webSocketState.isConnected) {
            webSocketNotifier.joinRoom(interestID: int.parse(interestId));
          }

          // Load messages
          await messagesNotifier.loadMessages(refresh: true);

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
        }
      });
      return null;
    }, []);

    // Handle WebSocket connection state changes
    useEffect(() {
      if (webSocketState.isConnected && authState.user != null) {
        // Join room when connected
        webSocketNotifier.joinRoom(interestID: int.parse(interestId));
      }
      return null;
    }, [webSocketState.isConnected]);

    // Handle WebSocket connection when auth state changes
    useEffect(() {
      // if (authState.user != null && !webSocketState.isConnected && !webSocketState.isConnecting) {
      //   webSocketNotifier.connectToChat(authState.user?.token);
      // }
      return null;
    }, [authState.user]);

    // Simplified version using the factory constructor

    void _handleNewWebSocketMessage() {
      final response = webSocketState.lastResponse;
      if (response == null) return;

      print('🔄 Processing WebSocket response: ${response.event}');

      if (response.event == 'send_message_response' &&
          response.isSuccess &&
          response.data != null) {
        final messageData = response.data!;
        final interestID = messageData['interestID'] as int?;

        if (interestID == int.parse(interestId)) {
          try {
            // Validate required fields
            if (messageData['senderID'] == null || authState.user?.id == null) {
              print('⚠️ Missing required fields for message processing');
              return;
            }

            print('📝 Creating message from WebSocket data: $messageData');

            // Use the factory constructor
            final message = Message.fromWebSocket(
              messageData,
              interestID: int.parse(interestId),
              currentUserId: authState.user!.id,
              otherUserId: displayUserId.value,
            );

            // Check if message already exists
            final existingMessage =
                messagesState.messages.where((m) {
                  if (messageData['id'] != null && m.id == messageData['id']) {
                    return true;
                  }
                  return m.message == message.message &&
                      m.senderID == message.senderID &&
                      m.createdAt != null &&
                      message.createdAt != null &&
                      m.createdAt!
                              .difference(message.createdAt!)
                              .abs()
                              .inSeconds <
                          3;
                }).firstOrNull;

            if (existingMessage == null) {
              print('✅ Adding new message to list');

              // ✅ Safely update provider outside build cycle
              messagesNotifier.addNewMessage(message);

              // Scroll to bottom after adding message
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  _scrollToBottom(scrollController);
                }
              });
            } else {
              print('⚠️ Duplicate message detected, skipping');
            }
          } catch (e) {
            print('❌ Error processing message: $e');
            print('❌ Message data: $messageData');
          }
        }
      }
    }

    useEffect(() {
      if (webSocketState.lastResponse != null) {
        print('📨 New WebSocket response detected, processing...');
        // ✅ Delay việc xử lý để tránh modify provider trong build cycle
        Future.microtask(_handleNewWebSocketMessage);
      }
      return null;
    }, [webSocketState.lastResponse]);

    // Handle WebSocket errors
    useEffect(() {
      if (webSocketState.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('WebSocket Error: ${webSocketState.error}'),
              backgroundColor: Colors.red,
            ),
          );
          webSocketNotifier.clearError();
        });
      }
      return null;
    }, [webSocketState.error]);

    // Handle pull to refresh (load more messages)
    // Trong InterestChatScreen, thay thế useEffect liên quan đến handleScroll bằng đoạn sau:

    useEffect(() {
      // Khởi tạo Debouncer với thời gian ngắn hơn
      final debouncer = Debouncer();

      // Hàm xử lý sự kiện cuộn
      void handleScroll() {
        // Kiểm tra nếu người dùng cuộn gần đến đầu danh sách (pixels <= 50)
        // và không đang trong quá trình tải thêm tin nhắn, đồng thời còn dữ liệu để tải
        if (scrollController.position.pixels <= 50 &&
            !messagesState.isLoadingMore &&
            messagesState.hasMoreData &&
            scrollController.hasClients) {
          // Sử dụng debouncer với thời gian chờ 500ms
          debouncer.debounce(
            duration: const Duration(milliseconds: 500),
            onDebounce: () async {
              // Lưu vị trí cuộn hiện tại và chiều cao tối đa của danh sách
              final currentScrollPosition = scrollController.position.pixels;
              final currentExtent = scrollController.position.maxScrollExtent;

              // Gọi hàm loadMore để tải thêm tin nhắn cũ
              await messagesNotifier.loadMore();

              // Đợi frame tiếp theo để đảm bảo giao diện đã được cập nhật
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  // Tính toán chiều cao mới của danh sách sau khi thêm tin nhắn
                  final newExtent = scrollController.position.maxScrollExtent;
                  final extentDelta = newExtent - currentExtent;

                  // Di chuyển mượt mà đến vị trí mới
                  scrollController.animateTo(
                    currentScrollPosition + extentDelta,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            },
          );
        }
      }

      // Gắn listener cho scrollController
      scrollController.addListener(handleScroll);

      // Cleanup: Xóa listener khi widget bị hủy
      return () => scrollController.removeListener(handleScroll);
    }, [messagesState.isLoadingMore, messagesState.hasMoreData]);
    // Handle transaction state changes
    useEffect(() {
      if (transactionsState.failure != null) {
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

    // Handle messages state changes
    useEffect(() {
      if (messagesState.failure != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lỗi tải tin nhắn: ${messagesState.failure!.message}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
      return null;
    }, [messagesState.failure]);

    // Cleanup when leaving the screen
    useEffect(() {
      return () {
        if (webSocketState.isConnected) {
          webSocketNotifier.leftRoom(interestID: int.parse(interestId));
        }
      };
    }, []);

    void sendMessage() async {
      final messageText = messageController.text.trim();
      if (messageText.isEmpty || isSending.value || authState.user == null)
        return;

      if (!webSocketState.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể gửi tin nhắn. Đang kết nối lại...'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      isSending.value = true;
      messageController.clear();

      try {
        print('📤 Sending message via WebSocket: $messageText');

        // Send message via WebSocket
        webSocketNotifier.sendMessage(
          interestID: int.parse(interestId),
          isOwner: isPostOwner.value,
          userID: displayUserId.value!,
          message: messageText,
        );
      } catch (e) {
        print('❌ Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi tin nhắn: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        isSending.value = false;
      }
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
              transactions: transactionsState.transactions,
              isPostOwner: isPostOwner.value,
              items: post.value?.items ?? [],
              onTransactionUpdated: (updatedTransaction) {
                // Transaction will be updated via provider
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

    if (isLoading.value || !authState.isInitialized) {
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

    if (authState.user == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: CustomAppBar(
          title: 'Trò chuyện',
          showBackButton: true,
          onBackPressed: () => context.pop(),
        ),
        body: const Center(
          child: Text('Bạn cần đăng nhập để sử dụng chức năng này'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: ChatAppBar(
        displayName: displayName.value,
        displayAvatar: displayAvatar.value,
        isPostOwner: isPostOwner.value,
        isTablet: isTablet,
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // WebSocket connection status indicator
            if (webSocketState.isConnecting)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đang kết nối...',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              )
            else if (!webSocketState.isConnected)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.signal_wifi_off, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Mất kết nối',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ),
              ),

            // Post info header
            if (post.value != null)
              PostInfoHeader(
                transactions: transactionsState.transactions,
                post: post.value!,
                isPostOwner: isPostOwner.value,
                isLoadingTransactions: transactionsState.isLoading,
                isTablet: isTablet,
                onPostTap: handlePostTap,
                onTransactionTap: handleTransactionTap,
                onRefreshTransactions: handleRefreshTransactions,
              ),

            // Messages list
            Expanded(
              child:
                  messagesState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: () => messagesNotifier.refresh(),
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index == 0 &&
                                      messagesState.isLoadingMore) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final messageIndex =
                                      messagesState.isLoadingMore
                                          ? index - 1
                                          : index;
                                  final message =
                                      messagesState.messages[messageIndex];

                                  final isCurrentUser =
                                      message.senderID == authState.user!.id;
                                  final showAvatar =
                                      messageIndex ==
                                          messagesState.messages.length - 1 ||
                                      messagesState
                                              .messages[messageIndex + 1]
                                              .senderID !=
                                          message.senderID;

                                  return _buildMessageBubble(
                                    message,
                                    isCurrentUser,
                                    showAvatar,
                                    isTablet,
                                    theme,
                                    colorScheme,
                                    displayName.value,
                                    displayAvatar.value,
                                    authState.user!.fullName,
                                    authState.user!.avatar,
                                    handlePostTap,
                                    messagesState.messages,
                                    messageIndex,
                                  );
                                },
                                childCount:
                                    messagesState.messages.length +
                                    (messagesState.isLoadingMore ? 1 : 0),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),

            // Message input
            _buildMessageInput(
              isTablet,
              theme,
              colorScheme,
              messageController,
              messageFocusNode,
              isSending.value || !webSocketState.isConnected,
              isPostOwner.value,
              sendMessage,
              handleItemTransactionTap,
              context,
              webSocketState.isConnected,
            ),
          ],
        ),
      ),
    );
  }
}

void _scrollToBottom(ScrollController scrollController) {
  if (scrollController.hasClients) {
    // Scroll xuống cuối cùng (bottom) thay vì lên đầu (top)
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

Widget _buildMessageBubble(
  Message message,
  bool isCurrentUser,
  bool showAvatar,
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  String otherUserName,
  String otherUserAvatar,
  String currentUserName,
  String currentUserAvatar,
  VoidCallback onPostTap,
  List<Message> messages,
  int messageIndex,
) {
  final senderAvatar = isCurrentUser ? currentUserAvatar : otherUserAvatar;

  bool shouldShowTime = false;

  if (messageIndex == messages.length - 1) {
    shouldShowTime = true;
  } else {
    final nextMessage = messages[messageIndex + 1];
    final currentTime = message.createdAt;
    final nextTime = nextMessage.createdAt;

    if (message.senderID != nextMessage.senderID) {
      shouldShowTime = true;
    } else if (currentTime != null && nextTime != null) {
      final timeDifference = nextTime.difference(currentTime).inMinutes;
      if (timeDifference > 15) {
        shouldShowTime = true;
      }

      if (currentTime.day != nextTime.day ||
          currentTime.month != nextTime.month ||
          currentTime.year != nextTime.year) {
        shouldShowTime = true;
      }
    }
  }

  return Container(
    margin: EdgeInsets.only(
      bottom: isTablet ? 12 : 8, // Tăng margin bottom
      left: isCurrentUser ? (isTablet ? 24 : 16) : 16, // Tăng padding trái
      right: isCurrentUser ? 16 : (isTablet ? 24 : 16), // Tăng padding phải
      top: 4, // Thêm margin top
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isCurrentUser) ...[
          if (showAvatar)
            _buildSenderAvatar(senderAvatar, isTablet, colorScheme)
          else
            SizedBox(
              width: isTablet ? 28 : 24,
            ), // Tăng width khi không có avatar
          SizedBox(width: isTablet ? 8 : 6), // Tăng khoảng cách sau avatar
        ],

        Flexible(
          child: Column(
            crossAxisAlignment:
                isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12, // Tăng padding ngang
                  vertical: isTablet ? 12 : 8, // Tăng padding dọc
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
                child: Text(
                  message.message,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    color:
                        isCurrentUser
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),

              if (shouldShowTime) ...[
                SizedBox(height: isTablet ? 4 : 2), // Tăng khoảng cách
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.createdAt != null
                          ? TimeUtils.formatTimeAgo(message.createdAt!)
                          : 'Vừa xong',
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 10,
                        color: theme.hintColor,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      SizedBox(width: isTablet ? 4 : 2),
                      Icon(
                        message.isRead == 1 ? Icons.done_all : Icons.done,
                        size: isTablet ? 14 : 12,
                        color:
                            message.isRead == 1 ? Colors.blue : theme.hintColor,
                      ),
                    ],
                  ],
                ),
              ],
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
  bool isWebSocketConnected,
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
                  hintText:
                      isWebSocketConnected
                          ? 'Nhập tin nhắn...'
                          : 'Đang kết nối...',
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
                enabled: !isSending && isWebSocketConnected,
              ),
            ),
          ),

          SizedBox(width: isTablet ? 8 : 4),

          // Send button
          Container(
            decoration: BoxDecoration(
              color:
                  isSending || !isWebSocketConnected
                      ? colorScheme.primary.withOpacity(0.5)
                      : colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isSending || !isWebSocketConnected ? null : onSend,
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
