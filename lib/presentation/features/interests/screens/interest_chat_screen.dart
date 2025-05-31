import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

// Model cho tin nhắn
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final String type; // text, image, location, post_info
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata; // cho post_info, location, v.v.

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
}

// Model cho thông tin cuộc trò chuyện
class ChatInfo {
  final String interestId;
  final String postId;
  final String postTitle;
  final String postType;
  final String postStatus;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final bool isOnline;
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
    required this.isOnline,
    this.lastSeen,
  });
}

class InterestChatScreen extends ConsumerStatefulWidget {
  final String interestId;

  const InterestChatScreen({Key? key, required this.interestId})
    : super(key: key);

  @override
  ConsumerState<InterestChatScreen> createState() => _InterestChatScreenState();
}

class _InterestChatScreenState extends ConsumerState<InterestChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  bool _isLoading = true;
  bool _isSending = false;
  ChatInfo? _chatInfo;
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Mock data - trong thực tế sẽ load từ API
    _chatInfo = const ChatInfo(
      interestId: 'interest_1',
      postId: '1',
      postTitle: 'Tìm chiếc ví da màu nâu bị mất tại quận 1',
      postType: 'findLost',
      postStatus: 'active',
      otherUserId: 'user1',
      otherUserName: 'Nguyễn Văn A',
      otherUserAvatar: '',
      isOnline: true,
      lastSeen: null,
    );

    // Mock messages
    _messages.addAll([
      ChatMessage(
        id: '1',
        senderId: 'user1',
        senderName: 'Nguyễn Văn A',
        senderAvatar: '',
        content: 'Xin chào! Tôi đã đăng bài tìm chiếc ví bị mất.',
        type: 'text',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      ChatMessage(
        id: '2',
        senderId: 'current_user',
        senderName: 'Bạn',
        senderAvatar: '',
        content:
            'Chào bạn! Tôi có thể giúp bạn tìm kiếm. Bạn có thể mô tả chi tiết hơn không?',
        type: 'text',
        createdAt: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 45),
        ),
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        senderId: 'user1',
        senderName: 'Nguyễn Văn A',
        senderAvatar: '',
        content: 'Cảm ơn bạn! Đây là thông tin chi tiết về chiếc ví:',
        type: 'text',
        createdAt: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 30),
        ),
        isRead: true,
      ),
      ChatMessage(
        id: '4',
        senderId: 'user1',
        senderName: 'Nguyễn Văn A',
        senderAvatar: '',
        content: '',
        type: 'post_info',
        createdAt: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 30),
        ),
        isRead: true,
        metadata: {
          'postId': '1',
          'title': 'Tìm chiếc ví da màu nâu bị mất tại quận 1',
          'type': 'findLost',
          'location': 'Quận 1, TP.HCM',
          'description':
              'Chiếc ví da màu nâu, bên trong có CMND và một số tiền mặt. Rất mong ai đó nhặt được có thể liên hệ.',
        },
      ),
      ChatMessage(
        id: '5',
        senderId: 'current_user',
        senderName: 'Bạn',
        senderAvatar: '',
        content: 'Tôi sẽ để ý và hỏi thêm bạn bè xung quanh khu vực đó.',
        type: 'text',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      ChatMessage(
        id: '6',
        senderId: 'user1',
        senderName: 'Nguyễn Văn A',
        senderAvatar: '',
        content: 'Cảm ơn bạn rất nhiều! 🙏',
        type: 'text',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: false,
      ),
    ]);

    setState(() {
      _isLoading = false;
    });

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    // Clear input immediately
    _messageController.clear();

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

    setState(() {
      _messages.add(newMessage);
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Simulate sending delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSending = false;
    });

    // Simulate auto reply after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final autoReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: _chatInfo!.otherUserId,
          senderName: _chatInfo!.otherUserName,
          senderAvatar: _chatInfo!.otherUserAvatar,
          content: 'Cảm ơn bạn đã nhắn tin! Tôi sẽ phản hồi sớm nhất có thể.',
          type: 'text',
          createdAt: DateTime.now(),
          isRead: false,
        );

        setState(() {
          _messages.add(autoReply);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });
  }

  void _handlePostTap() {
    if (_chatInfo != null) {
      context.pushNamed(
        'post-detail',
        pathParameters: {'id': _chatInfo!.postId},
      );
    }
  }

  void _handleUserProfileTap() {
    if (_chatInfo != null) {
      context.pushNamed(
        'user-profile',
        pathParameters: {'id': _chatInfo!.otherUserId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
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
      appBar: _buildAppBar(isTablet, theme, colorScheme),
      body: SafeArea(
        child: Column(
          children: [
            // Post info header
            if (_chatInfo != null)
              _buildPostInfoHeader(isTablet, theme, colorScheme),

            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 16 : 12,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isCurrentUser = message.senderId == 'current_user';
                  final showAvatar =
                      index == 0 ||
                      _messages[index - 1].senderId != message.senderId;

                  return _buildMessageBubble(
                    message,
                    isCurrentUser,
                    showAvatar,
                    isTablet,
                    theme,
                    colorScheme,
                  );
                },
              ),
            ),

            // Message input
            _buildMessageInput(isTablet, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: InkWell(
        onTap: _handleUserProfileTap,
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
                        _chatInfo!.otherUserAvatar.isNotEmpty
                            ? ClipOval(
                              child: Image.network(
                                _chatInfo!.otherUserAvatar,
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
                  // Online indicator
                  if (_chatInfo!.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: isTablet ? 12 : 10,
                        height: isTablet ? 12 : 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
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
                      _chatInfo!.otherUserName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _chatInfo!.isOnline
                          ? 'Đang online'
                          : _chatInfo!.lastSeen != null
                          ? 'Hoạt động ${_formatTimeAgo(_chatInfo!.lastSeen!)}'
                          : 'Offline',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color:
                            _chatInfo!.isOnline
                                ? Colors.green
                                : theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Show more options
            _showMoreOptions(context);
          },
          icon: const Icon(Icons.more_vert),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildPostInfoHeader(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: _handlePostTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(
              _getPostTypeIcon(_chatInfo!.postType),
              size: isTablet ? 24 : 20,
              color: _getTypeColor(_chatInfo!.postType),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Về bài đăng: ${_getTypeLabel(_chatInfo!.postType)}',
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: theme.hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isTablet ? 4 : 2),
                  Text(
                    _chatInfo!.postTitle,
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

  Widget _buildMessageBubble(
    ChatMessage message,
    bool isCurrentUser,
    bool showAvatar,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
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
                  child:
                      message.type == 'post_info'
                          ? _buildPostInfoMessage(
                            message,
                            isTablet,
                            theme,
                            colorScheme,
                            isCurrentUser,
                          )
                          : _buildTextMessage(
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
                      _formatMessageTime(message.createdAt),
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
            isCurrentUser
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }

  Widget _buildPostInfoMessage(
    ChatMessage message,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isCurrentUser,
  ) {
    final metadata = message.metadata!;

    return InkWell(
      onTap: _handlePostTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 8),
        decoration: BoxDecoration(
          color: (isCurrentUser ? colorScheme.onPrimary : colorScheme.surface)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isCurrentUser ? colorScheme.onPrimary : colorScheme.outline)
                .withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getPostTypeIcon(metadata['type']),
                  size: isTablet ? 16 : 14,
                  color:
                      isCurrentUser
                          ? colorScheme.onPrimary
                          : _getTypeColor(metadata['type']),
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  _getTypeLabel(metadata['type']),
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color:
                        isCurrentUser
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
                color:
                    isCurrentUser
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
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
                  color:
                      isCurrentUser
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
                  color:
                      isCurrentUser
                          ? colorScheme.onPrimary.withOpacity(0.7)
                          : theme.hintColor,
                ),
                SizedBox(width: isTablet ? 4 : 2),
                Text(
                  metadata['location'],
                  style: TextStyle(
                    fontSize: isTablet ? 11 : 10,
                    color:
                        isCurrentUser
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

  Widget _buildMessageInput(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
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
            // Attachment button
            IconButton(
              onPressed: () {
                _showAttachmentOptions(context);
              },
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
                  controller: _messageController,
                  focusNode: _messageFocusNode,
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
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isSending,
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
                onPressed: _isSending ? null : _sendMessage,
                icon:
                    _isSending
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

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Đính kèm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.photo,
                    label: 'Ảnh',
                    onTap: () {
                      Navigator.pop(context);
                      // Handle image attachment
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.location_on,
                    label: 'Vị trí',
                    onTap: () {
                      Navigator.pop(context);
                      // Handle location sharing
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.contact_phone,
                    label: 'Liên hệ',
                    onTap: () {
                      Navigator.pop(context);
                      // Handle contact sharing
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tùy chọn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Xem hồ sơ'),
                onTap: () {
                  Navigator.pop(context);
                  _handleUserProfileTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text('Xem bài đăng'),
                onTap: () {
                  Navigator.pop(context);
                  _handlePostTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Chặn người dùng'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showBlockUserDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Báo cáo'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showBlockUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chặn người dùng'),
          content: Text(
            'Bạn có chắc chắn muốn chặn ${_chatInfo!.otherUserName}? '
            'Bạn sẽ không thể nhận tin nhắn từ người này nữa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle block user
                _blockUser();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Chặn'),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Báo cáo người dùng'),
          content: const Text(
            'Bạn có muốn báo cáo người dùng này vì vi phạm quy định?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle report user
                _reportUser();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Báo cáo'),
            ),
          ],
        );
      },
    );
  }

  void _blockUser() {
    // TODO: Implement block user functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chặn ${_chatInfo!.otherUserName}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _reportUser() {
    // TODO: Implement report user functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã gửi báo cáo thành công')));
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}p';
    } else {
      return 'Vừa xong';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'vừa xong';
    }
  }

  IconData _getPostTypeIcon(String type) {
    switch (type) {
      case 'findLost':
        return Icons.search;
      case 'foundItem':
        return Icons.inventory;
      case 'giveAway':
        return Icons.card_giftcard;
      case 'exchange':
        return Icons.swap_horiz;
      default:
        return Icons.article;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'findLost':
        return Colors.orange;
      case 'foundItem':
        return Colors.green;
      case 'giveAway':
        return Colors.blue;
      case 'exchange':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'findLost':
        return 'Tìm đồ thất lạc';
      case 'foundItem':
        return 'Nhặt được đồ';
      case 'giveAway':
        return 'Tặng đồ';
      case 'exchange':
        return 'Trao đổi đồ';
      default:
        return 'Bài đăng';
    }
  }
}
