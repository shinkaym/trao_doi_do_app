import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/interested_user_section.dart';

/// Unified widget for displaying interest posts
/// Can show both interested posts and posts with interests based on the mode
class UnifiedInterestPostCard extends StatelessWidget {
  final InterestPost post;
  final PostType postType;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Function(String) handlePostTap;
  final Function(int) handleChatTap;
  final int? authUserId;
  // Optional parameters for interested posts mode
  final bool? isInterestLoading;
  final Function(int)? handleLikeTap;

  // Mode indicator
  final InterestPostCardMode mode;

  const UnifiedInterestPostCard({
    super.key,
    required this.post,
    required this.postType,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.handlePostTap,
    required this.handleChatTap,
    required this.mode,
    this.authUserId,
    this.isInterestLoading,
    this.handleLikeTap,
  });

  /// Factory constructor for interested posts (posts the user is interested in)
  factory UnifiedInterestPostCard.interestedPost({
    required InterestPost post,
    required PostType postType,
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Function(String) handlePostTap,
    required Function(int) handleChatTap,
    required Function(int) handleLikeTap,
    required bool isInterestLoading,
    int? authUserId,
  }) {
    return UnifiedInterestPostCard(
      post: post,
      postType: postType,
      isTablet: isTablet,
      theme: theme,
      colorScheme: colorScheme,
      handlePostTap: handlePostTap,
      handleChatTap: handleChatTap,
      handleLikeTap: handleLikeTap,
      isInterestLoading: isInterestLoading,
      authUserId: authUserId,
      mode: InterestPostCardMode.interestedPost,
    );
  }

  /// Factory constructor for posts with interests (user's posts that others are interested in)
  factory UnifiedInterestPostCard.postWithInterests({
    required InterestPost post,
    required PostType postType,
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Function(String) handlePostTap,
    required Function(int) handleChatTap,
    int? authUserId,
  }) {
    return UnifiedInterestPostCard(
      post: post,
      postType: postType,
      isTablet: isTablet,
      theme: theme,
      colorScheme: colorScheme,
      handlePostTap: handlePostTap,
      handleChatTap: handleChatTap,
      authUserId: authUserId,
      mode: InterestPostCardMode.postWithInterests,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        onTap: () => handlePostTap(post.slug),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              // Show author section only for interested posts
              if (mode == InterestPostCardMode.interestedPost) ...[
                SizedBox(height: isTablet ? 12 : 8),
                _buildAuthorSection(),
              ],
              SizedBox(height: isTablet ? 16 : 12),
              _buildPostContent(),
              // Only show latest message for interestedPost mode
              if (mode == InterestPostCardMode.interestedPost &&
                  _shouldShowLatestMessage()) ...[
                SizedBox(height: isTablet ? 12 : 8),
                _buildLatestMessageSection(),
              ],
              SizedBox(height: isTablet ? 16 : 12),
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget tạo badge tròn với số lượng tin nhắn chưa đọc
  Widget _buildRoundedBadge(int count) {
    final size = isTablet ? 22.0 : 18.0;
    final fontSize = isTablet ? 11.0 : 9.0;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Builds author section with avatar and name
  Widget _buildAuthorSection() {
    return Row(
      children: [
        _buildAuthorAvatar(),
        SizedBox(width: isTablet ? 12 : 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                TimeUtils.formatTimeAgo(DateTime.parse(post.createdAt)),
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorAvatar() {
    final radius = isTablet ? 16.0 : 14.0;

    if (post.authorAvatar.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(post.authorAvatar);

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
        size: isTablet ? 18 : 16,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// Kiểm tra có nên hiển thị tin nhắn gần nhất không (chỉ cho interestedPost mode)
  bool _shouldShowLatestMessage() {
    return post.interests.isNotEmpty &&
        post.interests.first.newMessage.isNotEmpty;
  }

  Widget _buildLatestMessageSection() {
    final interest = post.interests.first;
    final isUnread = interest.newMessageIsRead == 0;
    final isFromCurrentUser =
        authUserId != null && authUserId == interest.messageFromID;

    // Tạo text hiển thị tin nhắn
    String messageText;
    if (isFromCurrentUser) {
      messageText = 'Bạn: ${interest.newMessage}';
    } else {
      messageText = '${interest.newMessage}';
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color:
            isUnread
                ? colorScheme.primary.withOpacity(0.05)
                : colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border:
            isUnread
                ? Border.all(color: colorScheme.primary.withOpacity(0.2))
                : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: isTablet ? 16 : 14,
            color: isUnread ? colorScheme.primary : theme.hintColor,
          ),
          SizedBox(width: isTablet ? 8 : 6),
          Expanded(
            child: Text(
              messageText,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                color:
                    isUnread
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Hiển thị badge tròn số tin nhắn chưa đọc
          if (interest.unreadMessageCount > 0) ...[
            SizedBox(width: isTablet ? 8 : 6),
            _buildRoundedBadge(interest.unreadMessageCount),
          ],
        ],
      ),
    );
  }

  /// Builds the header section with post type and time
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 8,
            vertical: isTablet ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: postType.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                postType.icon,
                size: isTablet ? 16 : 14,
                color: postType.color,
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Text(
                postType.label,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w600,
                  color: postType.color,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Show time for both modes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              TimeUtils.formatTimeAgo(DateTime.parse(post.createdAt)),
              style: TextStyle(
                fontSize: isTablet ? 13 : 11,
                color: theme.hintColor,
              ),
            ),
            // Show unread message count badge only for postWithInterests mode
            if (mode == InterestPostCardMode.postWithInterests &&
                post.unreadMessageCount > 0) ...[
              SizedBox(width: isTablet ? 8 : 6),
              _buildRoundedBadge(post.unreadMessageCount),
            ],
          ],
        ),
      ],
    );
  }

  /// Builds the post content section
  Widget _buildPostContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isTablet ? 8 : 6),
              if (post.description.isNotEmpty)
                Text(
                  post.description,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 13,
                    color: colorScheme.onSurface.withOpacity(0.8),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the action section based on the mode
  Widget _buildActionSection() {
    switch (mode) {
      case InterestPostCardMode.interestedPost:
        return _buildInterestedPostActions();
      case InterestPostCardMode.postWithInterests:
        return _buildPostWithInterestsActions();
    }
  }

  /// Builds action buttons for interested posts (chat + like/unlike)
  Widget _buildInterestedPostActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildChatButton(),
        SizedBox(width: isTablet ? 8 : 6),
        _buildLikeButton(),
      ],
    );
  }

  /// Builds action section for posts with interests (shows interested users)
  Widget _buildPostWithInterestsActions() {
    if (post.interests.isEmpty) return const SizedBox.shrink();

    return InterestedUsersSection(
      post: post,
      isTablet: isTablet,
      theme: theme,
      colorScheme: colorScheme,
      handleChatTap: handleChatTap,
      authUserId: authUserId,
    );
  }

  /// Builds the chat button
  Widget _buildChatButton() {
    return InkWell(
      onTap: () => handleChatTap(post.interests[0].id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.chat_outlined,
          size: isTablet ? 20 : 18,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  /// Builds the like/unlike button for interested posts
  Widget _buildLikeButton() {
    final isLoading = isInterestLoading ?? false;

    return InkWell(
      onTap: isLoading ? null : () => handleLikeTap?.call(post.id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: isTablet ? 20 : 18,
                  height: isTablet ? 20 : 18,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red,
                  ),
                )
                : Icon(
                  Icons.favorite,
                  size: isTablet ? 20 : 18,
                  color: Colors.red,
                ),
      ),
    );
  }
}

/// Enum to define the mode of the interest post card
enum InterestPostCardMode {
  /// Shows posts that the user is interested in (with like/unlike functionality)
  interestedPost,

  /// Shows user's posts that others are interested in (with interested users list)
  postWithInterests,
}
