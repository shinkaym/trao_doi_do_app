import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/test/test.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/request_item_selection_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/request_list_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

class PostItem {
  final String id;
  final String name;
  final String image;
  final int quantity;

  const PostItem({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
  });
}

class ItemRequest {
  final String id;
  final String userId;
  final String postId;
  final List<RequestItem> items;
  final int status; // 0: pending, 1: accepted, 2: rejected
  final DateTime createdAt;
  final DateTime? updatedAt;

  ItemRequest({
    required this.id,
    required this.userId,
    required this.postId,
    required this.items,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
}

class RequestItem {
  final String itemId;
  final String itemName;
  final String itemImage;
  final int requestedQuantity;
  final int? approvedQuantity; // null nếu chưa được xử lý

  RequestItem({
    required this.itemId,
    required this.itemName,
    required this.itemImage,
    required this.requestedQuantity,
    this.approvedQuantity,
  });
}

final mockRequests = [
  ItemRequest(
    id: 'req1',
    userId: 'user1',
    postId: 'post1',
    items: [
      RequestItem(
        itemId: 'item1',
        itemName: 'Bút bi',
        itemImage: 'https://example.com/pen.jpg',
        requestedQuantity: 2,
      ),
    ],
    status: 0,
    createdAt: DateTime.now().subtract(Duration(hours: 2)),
  ),
];

final mockPostItems = [
  PostItem(
    id: 'item101',
    name: 'Balo học sinh',
    image: 'https://example.com/backpack.jpg',
    quantity: 3,
  ),
  PostItem(
    id: 'item102',
    name: 'Hộp bút',
    image: 'https://example.com/pencilcase.jpg',
    quantity: 5,
  ),
  PostItem(
    id: 'item103',
    name: 'Sách giáo khoa lớp 5',
    image: 'https://example.com/books.jpg',
    quantity: 2,
  ),
];

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

    // TODO: Thêm các state mới cho requests
    final requests = useState<List<ItemRequest>>([]);
    final isPostOwner = useState<bool>(false);

    // Initialize chat data
    useEffect(() {
      Future.microtask(() {
        chatInfo.value = mockChatInfo;
        messages.value = [...mockMessages];
        // TODO: Load thêm dữ liệu requests và isPostOwner từ API
        requests.value = mockRequests; // Cần tạo mock data
        isPostOwner.value = true; // Hoặc true tùy theo user hiện tại
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
      if (chatInfo.value != null) {
        context.pushNamed(
          'post-detail',
          pathParameters: {'id': chatInfo.value!.postId},
        );
      }
    }

    void handleRequestTap() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => RequestListBottomSheet(
              requests: requests.value,
              isPostOwner: isPostOwner.value,
              onRequestUpdated: (updatedRequest) {
                final index = requests.value.indexWhere(
                  (r) => r.id == updatedRequest.id,
                );
                if (index != -1) {
                  final updatedList = [...requests.value];
                  updatedList[index] = updatedRequest;
                  requests.value = updatedList;
                }
              },
            ),
      );
    }

    void handleItemRequestTap() {
      if (isPostOwner.value) return;
      final latestRequest =
          requests.value.isNotEmpty ? requests.value.last : null;
      final canCreateRequest =
          latestRequest == null || latestRequest.status != 0;
      if (!canCreateRequest) {
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
            (_) => RequestItemSelectionBottomSheet(
              postItems: mockPostItems,
              onRequestSent: () {
                // Optional: refresh request list
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
        chatInfo.value!,
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
                chatInfo.value!,
                requests.value,
                isPostOwner.value,
                handlePostTap,
                handleRequestTap,
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
              handleItemRequestTap,
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
  ChatInfo chatInfo,
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
            Stack(
              children: [
                CircleAvatar(
                  radius: isTablet ? 20 : 18,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  child:
                      chatInfo.otherUserAvatar.isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              chatInfo.otherUserAvatar,
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
              ],
            ),

            SizedBox(width: isTablet ? 12 : 8),

            // User info
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chatInfo.otherUserName,
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
  ChatInfo chatInfo,
  List<ItemRequest> requests,
  bool isPostOwner,
  VoidCallback onPostTap,
  VoidCallback onRequestTap,
) {
  // Sử dụng enum để lấy thông tin post type
  final postTypeEnum = _getPostTypeFromString(chatInfo.postType);
  final latestRequest = requests.isNotEmpty ? requests.last : null;

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
                  postTypeEnum?.icon ?? Icons.article,
                  size: isTablet ? 24 : 20,
                  color: postTypeEnum?.color ?? Colors.grey,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Về bài đăng: ${postTypeEnum?.label ?? 'Bài đăng'}',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        chatInfo.postTitle,
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

        // Latest request info
        if (latestRequest != null) ...[
          SizedBox(height: isTablet ? 8 : 6),
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
            ),
            child: InkWell(
              onTap: onRequestTap,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Icon(
                    _getRequestStatusIcon(latestRequest.status, isPostOwner),
                    size: isTablet ? 20 : 18,
                    color: _getRequestStatusColor(latestRequest.status),
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
                              TimeUtils.formatTimeAgo(latestRequest.createdAt),
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
                                color: _getRequestStatusColor(
                                  latestRequest.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getRequestStatusText(
                                  latestRequest.status,
                                  isPostOwner,
                                ),
                                style: TextStyle(
                                  fontSize: isTablet ? 11 : 10,
                                  color: _getRequestStatusColor(
                                    latestRequest.status,
                                  ),
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
  VoidCallback onItemRequest,
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
          // Request button (only for non-post-owner)
          if (!isPostOwner)
            IconButton(
              onPressed: onItemRequest,
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

// Helper functions for request status
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

// Helper function để lấy PostType từ string
PostType? _getPostTypeFromString(String typeString) {
  switch (typeString) {
    case 'giveAway':
      return PostType.giveAway;
    case 'foundItem':
      return PostType.foundItem;
    case 'findLost':
      return PostType.findLost;
    case 'freePost':
      return PostType.freePost;
    default:
      return null;
  }
}
