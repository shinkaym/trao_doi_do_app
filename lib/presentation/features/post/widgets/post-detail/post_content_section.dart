import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';

class PostContentSection extends HookConsumerWidget {
  final PostDetail post;
  final ValueNotifier<bool> showFullContent;
  final bool userInterested;
  final int interestCount;
  final VoidCallback onInterest;

  const PostContentSection({
    super.key,
    required this.post,
    required this.showFullContent,
    required this.userInterested,
    required this.interestCount,
    required this.onInterest,
  });

  bool isPostAuthor(PostDetail post, User? currentUser) {
    if (currentUser == null) return false;
    return post.authorID == currentUser.id;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(post, isTablet, theme, colorScheme, authState.user),

          SizedBox(height: isTablet ? 20 : 16),

          // Post Title
          Text(
            post.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Post Content
          _buildPostContentText(post, isTablet, theme, showFullContent),

          SizedBox(height: isTablet ? 20 : 16),

          // Post Details based on type
          _buildPostDetailsByType(post, isTablet, theme, colorScheme),

          // Tags
          if (post.tags.isNotEmpty) ...[
            SizedBox(height: isTablet ? 16 : 12),
            _buildTagsSection(post.tags, isTablet, theme, colorScheme),
          ],

          SizedBox(height: isTablet ? 20 : 16),
        ],
      ),
    );
  }

  Widget _buildPostHeader(
    PostDetail post,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    User? currentUser,
  ) {
    return Row(
      children: [
        // Author Avatar
        _buildAvatar(post, isTablet, theme),
        SizedBox(width: isTablet ? 16 : 12),

        // Author Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName ?? 'Người dùng',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Post Status Badge (hiển thị khi là chủ sở hữu)
        if (isPostAuthor(post, currentUser))
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PostStatus.fromValue(
                post.status ?? 0,
              ).color().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PostStatus.fromValue(
                  post.status ?? 0,
                ).color().withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PostStatus.fromValue(post.status ?? 0).icon(),
                  size: 12,
                  color: PostStatus.fromValue(post.status ?? 0).color(),
                ),
                const SizedBox(width: 4),
                Text(
                  PostStatus.fromValue(post.status ?? 0).label(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: PostStatus.fromValue(post.status ?? 0).color(),
                  ),
                ),
              ],
            ),
          ),

        // Post Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CreatePostType.fromValue(post.type).color().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            CreatePostType.fromValue(post.type).label(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: CreatePostType.fromValue(post.type).color(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(PostDetail post, bool isTablet, ThemeData theme) {
    final radius = isTablet ? 24.0 : 20.0;

    if (post.authorAvatar != null && post.authorAvatar!.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(post.authorAvatar!);

      if (imageBytes != null) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(imageBytes),
        );
      }
    }

    // Fallback về icon
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary,
      child: Icon(Icons.person, color: Colors.white, size: isTablet ? 18 : 16),
    );
  }

  Widget _buildPostContentText(
    PostDetail post,
    bool isTablet,
    ThemeData theme,
    ValueNotifier<bool> showFullContent,
  ) {
    final content = post.description;
    final shouldTruncate = content.length > 300 && !showFullContent.value;
    final displayContent =
        shouldTruncate ? '${content.substring(0, 300)}...' : content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayContent,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
        if (shouldTruncate) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showFullContent.value = true;
            },
            child: Text(
              'Xem thêm',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPostDetailsByType(
    PostDetail post,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Parse info JSON
    Map<String, dynamic> info = {};
    try {
      if (post.info.isNotEmpty && post.info != '{}') {
        info = jsonDecode(post.info);
      }
    } catch (e) {
      // Handle JSON parse error
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Type-specific details
          if (post.type == 2) ...[
            // Found Item - show found location and date
            if (info['foundLocation'] != null)
              _buildDetailRow(
                Icons.location_on,
                'Nơi nhặt được',
                info['foundLocation'],
                theme,
              ),
            if (info['foundDate'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.access_time,
                'Thời gian nhặt được',
                _formatDate(info['foundDate']),
                theme,
              ),
            ],
          ] else if (post.type == 3) ...[
            // Find Lost - show lost location, date, reward, category
            if (info['lostLocation'] != null)
              _buildDetailRow(
                Icons.location_on,
                'Nơi mất',
                info['lostLocation'],
                theme,
              ),
            if (info['lostDate'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.access_time,
                'Thời gian mất',
                _formatDate(info['lostDate']),
                theme,
              ),
            ],
            if (info['reward'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.card_giftcard,
                'Phần thưởng',
                '${info['reward']}',
                theme,
              ),
            ],
            if (info['category'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.category,
                'Loại đồ vật',
                info['category'],
                theme,
              ),
            ],
          ],

          // Common details
          if (post.createdAt != null) ...[
            if (post.type == 2 || post.type == 3) const SizedBox(height: 12),
            _buildDetailRow(
              Icons.schedule,
              'Thời gian đăng',
              TimeUtils.formatAbsolute(post.createdAt!),
              theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(
    List<String> tags,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách thẻ',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Không rõ';

    try {
      final date = DateTime.parse(dateString);
      return TimeUtils.formatTimeAgo(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }
}
