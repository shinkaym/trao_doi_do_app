import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/message.dart';

enum MessagePosition {
  single, // Tin nhắn đơn lẻ
  first, // Tin nhắn đầu tiên trong chuỗi
  middle, // Tin nhắn ở giữa chuỗi
  last, // Tin nhắn cuối cùng trong chuỗi
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final bool isTablet;
  final String otherUserName;
  final String otherUserAvatar;
  final String currentUserName;
  final String currentUserAvatar;
  final VoidCallback onPostTap;
  final List<Message> messages;
  final int messageIndex;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.isTablet,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.currentUserName,
    required this.currentUserAvatar,
    required this.onPostTap,
    required this.messages,
    required this.messageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final senderAvatar = isCurrentUser ? currentUserAvatar : otherUserAvatar;

    bool shouldShowTime = _shouldShowTime();
    MessagePosition position = _getMessagePosition();

    return Container(
      margin: EdgeInsets.only(
        bottom: _getBottomMargin(position),
        left: isCurrentUser ? (isTablet ? 24 : 16) : 16,
        right: isCurrentUser ? 16 : (isTablet ? 24 : 16),
        top: _getTopMargin(position),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            if (showAvatar)
              _buildSenderAvatar(senderAvatar, colorScheme)
            else
              SizedBox(width: isTablet ? 28 : 24),
            SizedBox(width: isTablet ? 8 : 6),
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
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 12 : 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isCurrentUser
                            ? colorScheme.primary
                            : colorScheme.surfaceVariant,
                    borderRadius: _getBorderRadius(position),
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
                  SizedBox(height: isTablet ? 4 : 2),
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
                              message.isRead == 1
                                  ? Colors.blue
                                  : theme.hintColor,
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

  MessagePosition _getMessagePosition() {
    final isFirstMessage = messageIndex == 0;
    final isLastMessage = messageIndex == messages.length - 1;

    final prevMessage = isFirstMessage ? null : messages[messageIndex - 1];
    final nextMessage = isLastMessage ? null : messages[messageIndex + 1];

    final hasPrevFromSameSender = prevMessage?.senderID == message.senderID;
    final hasNextFromSameSender = nextMessage?.senderID == message.senderID;

    if (!hasPrevFromSameSender && !hasNextFromSameSender) {
      return MessagePosition.single;
    } else if (!hasPrevFromSameSender && hasNextFromSameSender) {
      return MessagePosition.first;
    } else if (hasPrevFromSameSender && hasNextFromSameSender) {
      return MessagePosition.middle;
    } else {
      return MessagePosition.last;
    }
  }

  BorderRadius _getBorderRadius(MessagePosition position) {
    switch (position) {
      case MessagePosition.single:
        // Tin nhắn đơn lẻ - bo góc bình thường
        return BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
        );

      case MessagePosition.first:
        // Tin nhắn đầu tiên - ngược lại với last
        return BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
        );

      case MessagePosition.middle:
        // Tin nhắn ở giữa - chỉ bo góc theo hướng đối diện
        return BorderRadius.only(
          topLeft: Radius.circular(isCurrentUser ? 16 : 4),
          topRight: Radius.circular(isCurrentUser ? 4 : 16),
          bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
        );

      case MessagePosition.last:
        // Tin nhắn cuối cùng - giống single
        return BorderRadius.only(
          topLeft: Radius.circular(isCurrentUser ? 16 : 4),
          topRight: Radius.circular(isCurrentUser ? 4 : 16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        );
    }
  }

  double _getTopMargin(MessagePosition position) {
    if (position == MessagePosition.first ||
        position == MessagePosition.single) {
      return 8.0;
    }
    return 2.0; // Khoảng cách nhỏ cho tin nhắn liên tiếp
  }

  double _getBottomMargin(MessagePosition position) {
    if (position == MessagePosition.last ||
        position == MessagePosition.single) {
      return isTablet ? 12 : 8;
    }
    return 2.0; // Khoảng cách nhỏ cho tin nhắn liên tiếp
  }

  bool _shouldShowTime() {
    if (messageIndex == messages.length - 1) {
      return true;
    }

    final nextMessage = messages[messageIndex + 1];
    final currentTime = message.createdAt;
    final nextTime = nextMessage.createdAt;

    if (message.senderID != nextMessage.senderID) {
      return true;
    }

    if (currentTime != null && nextTime != null) {
      final timeDifference = nextTime.difference(currentTime).inMinutes;
      if (timeDifference > 15) {
        return true;
      }

      if (currentTime.day != nextTime.day ||
          currentTime.month != nextTime.month ||
          currentTime.year != nextTime.year) {
        return true;
      }
    }

    return false;
  }

  Widget _buildSenderAvatar(String senderAvatar, ColorScheme colorScheme) {
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
}
