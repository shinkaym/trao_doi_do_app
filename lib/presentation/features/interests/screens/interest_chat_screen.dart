import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

enum MessageType { text, image, location, postInfo }

// Models
@immutable
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.metadata,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}

@immutable
class ChatInfo {
  final String interestId;
  final String postId;
  final String postTitle;
  final PostType postType;
  final String postStatus;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final DateTime? lastSeen;

  const ChatInfo({
    required this.interestId,
    required this.postId,
    required this.postTitle,
    required this.postType,
    required this.postStatus,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    this.lastSeen,
  });
}

@immutable
class ChatState {
  final bool isLoading;
  final bool isSending;
  final ChatInfo? chatInfo;
  final List<ChatMessage> messages;
  final String? error;

  const ChatState({
    this.isLoading = true,
    this.isSending = false,
    this.chatInfo,
    this.messages = const [],
    this.error,
  });

  ChatState copyWith({
    bool? isLoading,
    bool? isSending,
    ChatInfo? chatInfo,
    List<ChatMessage>? messages,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      chatInfo: chatInfo ?? this.chatInfo,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}

// Providers
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this.interestId) : super(const ChatState()) {
    _initializeChat();
  }

  final String interestId;

  void _initializeChat() async {
    // Simulate API loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    final chatInfo = ChatInfo(
      interestId: interestId,
      postId: '1',
      postTitle: 'Tìm chiếc ví da màu nâu bị mất tại quận 1',
      postType: PostType.findLost,
      postStatus: 'active',
      otherUserId: 'user1',
      otherUserName: 'Nguyễn Văn A',
      otherUserAvatar: '',
      lastSeen: null,
    );

    final messages = _getMockMessages();

    state = state.copyWith(
      isLoading: false,
      chatInfo: chatInfo,
      messages: messages,
    );
  }

  List<ChatMessage> _getMockMessages() {
    return [
      ChatMessage(
        id: '1',
        senderId: 'user1',
        senderName: 'Nguyễn Văn A',
        senderAvatar: '',
        content: 'Xin chào! Tôi đã đăng bài tìm chiếc ví bị mất.',
        type: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      ChatMessage(
        id: '2',
        senderId: 'current_user',
        senderName: 'Bạn',
        senderAvatar: '',
        content: 'Chào bạn! Tôi có thể giúp bạn tìm kiếm. Bạn có thể mô tả chi tiết hơn không?',
        type: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        senderId: 'user1',
        senderName: 'Nguyễn Văn A',
        senderAvatar: '',
        content: 'Cảm ơn bạn! Đây là thông tin chi tiết về chiếc ví:',
        type: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isRead: true,
      ),
      ChatMessage(
        id: '4',
        senderId: 'user1',
        senderName: 'Nguyễn Văn A',
        senderAvatar: '',
        content: '',
        type: MessageType.postInfo,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isRead: true,
        metadata: {
          'postId': '1',
          'title': 'Tìm chiếc ví da màu nâu bị mất tại quận 1',
          'type': 'findLost',
          'location': 'Quận 1, TP.HCM',
          'description': 'Chiếc ví da màu nâu, bên trong có CMND và một số tiền mặt. Rất mong ai đó nhặt được có thể liên hệ.',
        },
      ),
      ChatMessage(
        id: '5',
        senderId: 'current_user',
        senderName: 'Bạn',
        senderAvatar: '',
        content: 'Tôi sẽ để ý và hỏi thêm bạn bè xung quanh khu vực đó.',
        type: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      ChatMessage(
        id: '6',
        senderId: 'user1',
        senderName: 'Nguyễn Văn A',
        senderAvatar: '',
        content: 'Cảm ơn bạn rất nhiều! 🙏',
        type: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: false,
      ),
    ];
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isSending) return;

    state = state.copyWith(isSending: true);

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'Bạn',
      senderAvatar: '',
      content: content.trim(),
      type: MessageType.text,
      createdAt: DateTime.now(),
      isRead: false,
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
    );

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(isSending: false);

    // Simulate auto reply
    _simulateAutoReply();
  }

  void _simulateAutoReply() {
    Future.delayed(const Duration(seconds: 2), () {
      if (state.chatInfo != null) {
        final autoReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: state.chatInfo!.otherUserId,
          senderName: state.chatInfo!.otherUserName,
          senderAvatar: state.chatInfo!.otherUserAvatar,
          content: 'Cảm ơn bạn đã nhắn tin! Tôi sẽ phản hồi sớm nhất có thể.',
          type: MessageType.text,
          createdAt: DateTime.now(),
          isRead: false,
        );

        state = state.copyWith(
          messages: [...state.messages, autoReply],
        );
      }
    });
  }

  void markMessagesAsRead() {
    final updatedMessages = state.messages.map((message) {
      if (message.senderId != 'current_user' && !message.isRead) {
        return message.copyWith(isRead: true);
      }
      return message;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, interestId) => ChatNotifier(interestId),
);

// Main Screen Widget
class InterestChatScreen extends HookConsumerWidget {
  final String interestId;

  const InterestChatScreen({
    super.key,
    required this.interestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider(interestId));
    final chatNotifier = ref.read(chatProvider(interestId).notifier);
    
    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final messageFocusNode = useFocusNode();

    // Auto scroll to bottom when new messages arrive
    useEffect(() {
      if (chatState.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(scrollController);
        });
      }
      return null;
    }, [chatState.messages.length]);

    // Auto focus and scroll when sending
    useEffect(() {
      if (!chatState.isSending && messageController.text.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(scrollController);
        });
      }
      return null;
    }, [chatState.isSending]);

    final theme = context.theme;
    final colorScheme = context.colorScheme;

    if (chatState.isLoading) {
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

    if (chatState.error != null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: CustomAppBar(
          title: 'Trò chuyện',
          showBackButton: true,
          onBackPressed: () => context.pop(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra: ${chatState.error}',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => chatNotifier._initializeChat(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _ChatAppBar(chatInfo: chatState.chatInfo!),
      body: SafeArea(
        child: Column(
          children: [
            // Post info header
            _PostInfoHeader(chatInfo: chatState.chatInfo!),

            // Messages list
            Expanded(
              child: _MessagesList(
                messages: chatState.messages,
                scrollController: scrollController,
              ),
            ),

            // Message input
            _MessageInput(
              controller: messageController,
              focusNode: messageFocusNode,
              isSending: chatState.isSending,
              onSend: (message) {
                chatNotifier.sendMessage(message);
                messageController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

// Component Widgets
class _ChatAppBar extends HookConsumerWidget implements PreferredSizeWidget {
  final ChatInfo chatInfo;

  const _ChatAppBar({required this.chatInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: InkWell(
        onTap: () => _handleUserProfileTap(context, chatInfo.otherUserId),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UserAvatar(
                avatar: chatInfo.otherUserAvatar,
                radius: isTablet ? 20 : 18,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Flexible(
                child: Text(
                  chatInfo.otherUserName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
    );
  }

  void _handleUserProfileTap(BuildContext context, String userId) {
    context.pushNamed(
      'user-profile',
      pathParameters: {'id': userId},
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

class _UserAvatar extends StatelessWidget {
  final String avatar;
  final double radius;

  const _UserAvatar({
    required this.avatar,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primary.withOpacity(0.1),
      child: avatar.isNotEmpty
          ? ClipOval(
              child: Image.network(
                avatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: radius,
                    color: colorScheme.primary,
                  );
                },
              ),
            )
          : Icon(
              Icons.person,
              size: radius,
              color: colorScheme.primary,
            ),
    );
  }
}

class _PostInfoHeader extends StatelessWidget {
  final ChatInfo chatInfo;

  const _PostInfoHeader({required this.chatInfo});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Container(
      margin: EdgeInsets.all(isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => _handlePostTap(context, chatInfo.postId),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(
              chatInfo.postType.icon,
              size: isTablet ? 24 : 20,
              color: chatInfo.postType.color,
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Về bài đăng: ${chatInfo.postType.label}',
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
    );
  }

  void _handlePostTap(BuildContext context, String postId) {
    context.pushNamed(
      'post-detail',
      pathParameters: {'id': postId},
    );
  }
}

class _MessagesList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const _MessagesList({
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.senderId == 'current_user';
        final showAvatar = index == 0 || messages[index - 1].senderId != message.senderId;

        return _MessageBubble(
          message: message,
          isCurrentUser: isCurrentUser,
          showAvatar: showAvatar,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Container(
      margin: EdgeInsets.only(
        bottom: isTablet ? 8 : 6,
        left: isCurrentUser ? (isTablet ? 60 : 40) : 0,
        right: isCurrentUser ? 0 : (isTablet ? 60 : 40),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar for received messages
          if (!isCurrentUser) ...[
            if (showAvatar)
              _UserAvatar(
                avatar: message.senderAvatar,
                radius: isTablet ? 14 : 12,
              )
            else
              SizedBox(width: isTablet ? 28 : 24),
            SizedBox(width: isTablet ? 8 : 6),
          ],

          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 12 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? colorScheme.primary : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                      bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                    ),
                  ),
                  child: message.type == MessageType.postInfo
                      ? _PostInfoMessage(message: message, isCurrentUser: isCurrentUser)
                      : _TextMessage(message: message, isCurrentUser: isCurrentUser),
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
}

class _TextMessage extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;

  const _TextMessage({
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    return Text(
      message.content,
      style: TextStyle(
        fontSize: isTablet ? 15 : 14,
        color: isCurrentUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }
}

class _PostInfoMessage extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;

  const _PostInfoMessage({
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final metadata = message.metadata!;
    final postType = PostType.fromString(metadata['type']);

    return InkWell(
      onTap: () => _handlePostTap(context, metadata['postId']),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 8),
        decoration: BoxDecoration(
          color: (isCurrentUser ? colorScheme.onPrimary : colorScheme.surface).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isCurrentUser ? colorScheme.onPrimary : colorScheme.outline).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  postType.icon,
                  size: isTablet ? 16 : 14,
                  color: isCurrentUser ? colorScheme.onPrimary : postType.color,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  postType.label,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: isCurrentUser
                        ? colorScheme.onPrimary.withOpacity(0.8)
                        : theme.hintColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              metadata['title'],
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: isCurrentUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (metadata['description'] != null) ...[
              SizedBox(height: isTablet ? 6 : 4),
              Text(
                metadata['description'],
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: isCurrentUser
                      ? colorScheme.onPrimary.withOpacity(0.8)
                      : theme.hintColor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: isTablet ? 6 : 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: isTablet ? 12 : 10,
                  color: isCurrentUser
                      ? colorScheme.onPrimary.withOpacity(0.7)
                      : theme.hintColor,
                ),
                SizedBox(width: isTablet ? 4 : 2),
                Text(
                  metadata['location'],
                  style: TextStyle(
                    fontSize: isTablet ? 11 : 10,
                    color: isCurrentUser
                        ? colorScheme.onPrimary.withOpacity(0.7)
                        : theme.hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handlePostTap(BuildContext context, String postId) {
    context.pushNamed(
      'post-detail',
      pathParameters: {'id': postId},
    );
  }
}

class _MessageInput extends HookWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final Function(String) onSend;

  const _MessageInput({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            IconButton(
              onPressed: () => _showAttachmentOptions(context),
              icon: const Icon(Icons.attach_file),
              style: IconButton.styleFrom(foregroundColor: colorScheme.primary),
            ),

            SizedBox(width: isTablet ? 8 : 4),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
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
                  onSubmitted: (_) => _handleSend(controller.text),
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
                onPressed: isSending ? null : () => _handleSend(controller.text),
                icon: isSending
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

  void _handleSend(String message) {
    if (message.trim().isNotEmpty) {
      onSend(message);
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isTablet = context.isTablet;
        
        return Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              Text(
                'Đính kèm',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachmentOption(
                    icon: Icons.photo,
                    label: 'Ảnh',
                    onTap: () {
                      context.pop();
                      // Handle image attachment
                    },
                  ),
                  _AttachmentOption(
                    icon: Icons.location_on,
                    label: 'Vị trí',
                    onTap: () {
                      context.pop();
                      // Handle location sharing
                    },
                  ),
                  _AttachmentOption(
                    icon: Icons.contact_phone,
                    label: 'Liên hệ',
                    onTap: () {
                      context.pop();
                      // Handle contact sharing
                    },
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 24 : 20),
            ],
          ),
        );
      },
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: isTablet ? 36 : 32,
              color: colorScheme.primary,
            ),
            SizedBox(height: isTablet ? 10 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}