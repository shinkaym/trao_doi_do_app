import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final PostType postType;
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final void Function(Post)? onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.postType,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap != null ? () => onTap!(post) : null,
        child: Container(
          height: isTablet ? 160 : 140,
          child: Row(
            children: [
              // Left side - Image with overlays
              _PostImage(
                post: post,
                postType: postType,
                isTablet: isTablet,
                colorScheme: colorScheme,
                theme: theme,
              ),

              // Right side - Information
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  child: _buildContentLayout(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentLayout() {
    final location = _getLocationFromPost();
    final reward = _getRewardFromPost();
    final hasInfo =
        location.isNotEmpty || (reward != null && reward.isNotEmpty);

    if (hasInfo) {
      // Layout có thông tin info - giữ nguyên layout cũ
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTitleAndDescription(),
          _buildLocationAndReward(),
          _buildTimeAtBottom(),
        ],
      );
    } else {
      // Layout không có info - phân bố đều không gian
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title và description chiếm không gian chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                  maxLines: 2, // Tăng số dòng cho title khi không có info
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Text(
                  post.description,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    color: colorScheme.onSurface.withOpacity(0.7),
                    height: 1.3,
                  ),
                  maxLines: 3, // Tăng số dòng cho description
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Time ở dưới cùng
          if (post.createdAt != null)
            Padding(
              padding: EdgeInsets.only(top: isTablet ? 8 : 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    TimeUtils.formatTimeAgo(post.createdAt!),
                    style: TextStyle(
                      fontSize: isTablet ? 10 : 9,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
  }

  Widget _buildTitleAndDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: TextStyle(
            fontSize: isTablet ? 15 : 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isTablet ? 6 : 4),
        Text(
          post.description,
          style: TextStyle(
            fontSize: isTablet ? 12 : 11,
            color: colorScheme.onSurface.withOpacity(0.7),
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLocationAndReward() {
    final location = _getLocationFromPost();
    final reward = _getRewardFromPost();

    if (location.isEmpty && reward == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (location.isNotEmpty)
          _InfoChip(
            icon: Icons.location_on,
            text: location,
            color: Colors.blue.shade700,
            backgroundColor: Colors.blue.withOpacity(0.1),
            isTablet: isTablet,
          ),
        if (reward != null && reward.isNotEmpty)
          _InfoChip(
            icon: Icons.card_giftcard,
            text: 'Thưởng: $reward',
            color: Colors.orange.shade700,
            backgroundColor: Colors.orange.withOpacity(0.1),
            isTablet: isTablet,
          ),
      ],
    );
  }

  Widget _buildTimeAtBottom() {
    if (post.createdAt == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          TimeUtils.formatTimeAgo(post.createdAt!),
          style: TextStyle(fontSize: isTablet ? 10 : 9, color: theme.hintColor),
        ),
      ],
    );
  }

  String _getLocationFromPost() {
    try {
      if (post.info.isNotEmpty) {
        final infoData = jsonDecode(post.info);
        return infoData['foundLocation'] ??
            infoData['lostLocation'] ??
            infoData['location'] ??
            '';
      }
    } catch (e) {
      // Handle JSON parsing error
    }
    return '';
  }

  String? _getRewardFromPost() {
    try {
      if (post.info.isNotEmpty) {
        final infoData = jsonDecode(post.info);
        final reward = infoData['reward'];
        return (reward != null && reward.toString().isNotEmpty)
            ? reward.toString()
            : null;
      }
    } catch (e) {
      // Handle JSON parsing error
    }
    return null;
  }
}

class _PostImage extends StatelessWidget {
  final Post post;
  final PostType postType;
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _PostImage({
    required this.post,
    required this.postType,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isTablet ? 140 : 120,
      child: Stack(
        children: [
          // Main image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child:
                post.images.isNotEmpty
                    ? _buildImage(post.images.first)
                    : _buildPlaceholder(),
          ),

          // Interest count overlay (top-right)
          if (post.interestCount != null && post.interestCount! > 0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 10),
                    SizedBox(width: 2),
                    Text(
                      '${post.interestCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 10 : 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Item count overlay (bottom)
          if (postType != PostType.freePost &&
              post.itemCount != null &&
              post.currentItemCount != null)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      post.currentItemCount! > 0
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  post.currentItemCount! > 0
                      ? 'Còn ${post.currentItemCount}/${post.itemCount}'
                      : 'Hết đồ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 10 : 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageData) {
    if (imageData.startsWith('data:')) {
      try {
        final bytes = Base64Utils.decodeImageFromBase64(imageData);
        if (bytes != null) {
          return Image.memory(
            bytes,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    return Image.network(
      imageData,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: isTablet ? 32 : 28,
        color: theme.hintColor,
      ),
    );
  }
}

// New unified component for location and reward info
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color backgroundColor;
  final bool isTablet;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
    required this.backgroundColor,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 4 : 3),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 6,
        vertical: isTablet ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 13 : 11, color: color),
          SizedBox(width: isTablet ? 4 : 3),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isTablet ? 11 : 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
