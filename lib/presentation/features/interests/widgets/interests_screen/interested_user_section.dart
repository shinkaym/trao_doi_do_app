import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';

class InterestedUsersSection extends StatefulWidget {
  final InterestPost post;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Function(int) handleChatTap;
  final int? authUserId;

  const InterestedUsersSection({
    super.key,
    required this.post,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.handleChatTap,
    this.authUserId,
  });

  @override
  State<InterestedUsersSection> createState() => InterestedUsersSectionState();
}

class InterestedUsersSectionState extends State<InterestedUsersSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Interest count header with tap to expand
        InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? 12 : 8,
              vertical: widget.isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  size: widget.isTablet ? 16 : 14,
                  color: Colors.red,
                ),
                SizedBox(width: widget.isTablet ? 6 : 4),
                Text(
                  '${widget.post.interests.length} người quan tâm',
                  style: TextStyle(
                    fontSize: widget.isTablet ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: widget.isTablet ? 8 : 6),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: widget.isTablet ? 18 : 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated collapse content
        SizeTransition(
          sizeFactor: _animation,
          child: Container(
            margin: EdgeInsets.only(top: widget.isTablet ? 12 : 8),
            constraints: BoxConstraints(
              maxHeight: 200, // Limit height to show max 3 users initially
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.post.interests.length,
              itemBuilder: (context, index) {
                final interest = widget.post.interests[index];
                return _buildInterestedUserCard(interest);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestedUserCard(Interest interest) {
    final hasNewMessage = interest.newMessage.isNotEmpty;
    final isUnread = interest.newMessageIsRead == 0;
    final isFromCurrentUser =
        widget.authUserId != null &&
        widget.authUserId == interest.messageFromID;

    return Container(
      margin: EdgeInsets.only(bottom: widget.isTablet ? 8 : 6),
      padding: EdgeInsets.all(widget.isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildInterestAvatar(interest),
          SizedBox(width: widget.isTablet ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  interest.userName,
                  style: TextStyle(
                    fontSize: widget.isTablet ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    color: widget.colorScheme.onSurface,
                  ),
                ),

                // Latest message or interest time
                SizedBox(height: widget.isTablet ? 4 : 3),
                if (hasNewMessage) ...[
                  _buildLatestMessagePreview(
                    interest,
                    isUnread,
                    isFromCurrentUser,
                  ),
                ] else ...[
                  Text(
                    'Chưa có tin nhắn',
                    style: TextStyle(
                      fontSize: widget.isTablet ? 12 : 11,
                      color: widget.theme.hintColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Chat button with notification badge
          _buildChatButtonWithBadge(interest),
        ],
      ),
    );
  }

  Widget _buildLatestMessagePreview(
    Interest interest,
    bool isUnread,
    bool isFromCurrentUser,
  ) {
    // Create message text
    String messageText;
    if (isFromCurrentUser) {
      messageText = 'Bạn: ${interest.newMessage}';
    } else {
      messageText = interest.newMessage;
    }

    return Text(
      messageText,
      style: TextStyle(
        fontSize: widget.isTablet ? 12 : 11,
        fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
        color:
            isUnread
                ? widget.colorScheme.primary
                : widget.colorScheme.onSurface.withOpacity(0.7),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildChatButtonWithBadge(Interest interest) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () => widget.handleChatTap(interest.id),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.all(widget.isTablet ? 8 : 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.chat_outlined,
              size: widget.isTablet ? 16 : 14,
              color: widget.colorScheme.primary,
            ),
          ),
        ),
        // Notification badge
        if (interest.unreadMessageCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: EdgeInsets.all(widget.isTablet ? 4 : 3),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: widget.isTablet ? 18 : 16,
                minHeight: widget.isTablet ? 18 : 16,
              ),
              child: Text(
                interest.unreadMessageCount > 99
                    ? '99+'
                    : interest.unreadMessageCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isTablet ? 10 : 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInterestAvatar(Interest interest) {
    final radius = widget.isTablet ? 16.0 : 14.0;

    if (interest.userAvatar.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(interest.userAvatar);

      if (imageBytes != null) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(imageBytes),
        );
      }
    }

    // Fallback to icon
    return CircleAvatar(
      radius: radius,
      backgroundColor: widget.colorScheme.primary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        color: widget.colorScheme.primary,
        size: widget.isTablet ? 16 : 14,
      ),
    );
  }
}
