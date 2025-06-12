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

const mockChatInfo = ChatInfo(
  interestId: 'interest_1',
  postId: '1',
  postTitle: 'Tìm chiếc ví da màu nâu bị mất tại quận 1',
  postType: 'findLost',
  postStatus: 'active',
  otherUserId: 'user1',
  otherUserName: 'Nguyễn Văn A',
  otherUserAvatar: '',
  lastSeen: null,
);

final mockMessages = <ChatMessage>[
  ChatMessage(
    id: '1',
    senderId: 'user1',
    senderName: 'Nguyễn Văn A',
    senderAvatar: '',
    content: 'Xin chào! Tôi đã đăng bài tìm chiếc ví bị mất.',
    type: 'text',
    createdAt: DateTime.now().subtract(Duration(hours: 2)),
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
    createdAt: DateTime.now().subtract(Duration(hours: 1, minutes: 45)),
    isRead: true,
  ),
  ChatMessage(
    id: '3',
    senderId: 'user1',
    senderName: 'Nguyễn Văn A',
    senderAvatar: '',
    content: 'Cảm ơn bạn! Đây là thông tin chi tiết về chiếc ví:',
    type: 'text',
    createdAt: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '5',
    senderId: 'current_user',
    senderName: 'Bạn',
    senderAvatar: '',
    content: 'Tôi sẽ để ý và hỏi thêm bạn bè xung quanh khu vực đó.',
    type: 'text',
    createdAt: DateTime.now().subtract(Duration(minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '6',
    senderId: 'user1',
    senderName: 'Nguyễn Văn A',
    senderAvatar: '',
    content: 'Cảm ơn bạn rất nhiều! 🙏',
    type: 'text',
    createdAt: DateTime.now().subtract(Duration(minutes: 25)),
    isRead: false,
  ),
];
