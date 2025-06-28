import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';

class PostInterestsSection extends StatelessWidget {
  final List<PostInterest> interests;
  final VoidCallback? onShowAllUsers;
  final Function(PostInterest)? onUserTap;

  const PostInterestsSection({
    Key? key,
    required this.interests,
    this.onShowAllUsers,
    this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(interests, isTablet, theme, colorScheme),
          const SizedBox(height: 16),
          interests.isEmpty
              ? _buildEmptyState(theme, colorScheme, isTablet)
              : _buildInterestsList(interests, isTablet, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    List<PostInterest> interests,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.05), Colors.pink.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.red,
              size: isTablet ? 20 : 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Người quan tâm',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (interests.isNotEmpty)
                  Text(
                    _getInterestText(interests.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: isTablet ? 13 : 12,
                    ),
                  ),
              ],
            ),
          ),
          if (interests.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 10,
                vertical: isTablet ? 6 : 5,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    size: isTablet ? 14 : 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${interests.length}',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: isTablet ? 32 : 28,
              color: colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có ai quan tâm',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hãy chia sẻ bài đăng để thu hút sự quan tâm',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsList(
    List<PostInterest> interests,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Hiển thị tối đa 6 người đầu tiên
    final displayCount = interests.length > 6 ? 6 : interests.length;
    final hasMore = interests.length > 6;

    return Column(
      children: [
        Container(
          height: isTablet ? 110 : 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: displayCount + (hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (hasMore && index == displayCount) {
                return _buildMoreUsersIndicator(
                  interests.length - displayCount,
                  isTablet,
                  theme,
                  colorScheme,
                );
              }

              return _buildUserCard(
                interests[index],
                isTablet,
                theme,
                colorScheme,
              );
            },
          ),
        ),
        if (hasMore) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onShowAllUsers,
            icon: Icon(Icons.expand_more, size: isTablet ? 18 : 16),
            label: Text(
              'Xem tất cả ${interests.length} người',
              style: TextStyle(fontSize: isTablet ? 14 : 13),
            ),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 8 : 6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUserCard(
    PostInterest interest,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () => onUserTap?.call(interest),
      child: Container(
        width: isTablet ? 80 : 70,
        child: Column(
          children: [
            Container(
              width: isTablet ? 56 : 48,
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildUserAvatar(interest, isTablet, theme, colorScheme),
            ),
            const SizedBox(height: 8),
            Text(
              _truncateUserName(interest.userName, 12),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: isTablet ? 12 : 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Container(
              width: isTablet ? 20 : 16,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.6),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreUsersIndicator(
    int moreCount,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onShowAllUsers,
      child: Container(
        width: isTablet ? 80 : 70,
        child: Column(
          children: [
            Container(
              width: isTablet ? 56 : 48,
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.1),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add,
                color: colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+$moreCount',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: isTablet ? 12 : 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(
    PostInterest interest,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final radius = isTablet ? 24.0 : 20.0;

    if (interest.userAvatar.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(interest.userAvatar);

      if (imageBytes != null) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(imageBytes),
          backgroundColor: Colors.grey[200],
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        interest.userName.isNotEmpty ? interest.userName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  String _getInterestText(int count) {
    if (count == 1) return '1 người đã quan tâm';
    return '$count người đã quan tâm';
  }

  String _truncateUserName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }
}
