import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'dart:convert';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final void Function(Post) onTap;
  final Color Function(PostType) getTypeColor;
  final bool Function(Post) hasImages;
  final String? Function(Post) getRewardFromPost;
  final String Function(Post) getLocationFromPost;

  const PostCard({
    super.key,
    required this.post,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.onTap,
    required this.getTypeColor,
    required this.hasImages,
    required this.getRewardFromPost,
    required this.getLocationFromPost,
  });

  @override
  Widget build(BuildContext context) {
    final postType = PostType.values.firstWhere(
      (type) => type.value == post.type,
      orElse: () => PostType.all,
    );

    final reward = getRewardFromPost(post);
    final location = getLocationFromPost(post);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: InkWell(
          onTap: () => onTap(post),
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow(postType),
                SizedBox(height: isTablet ? 16 : 12),
                _buildTitleAndDescription(),
                if (hasImages(post)) _buildImagesSection(),
                SizedBox(height: isTablet ? 16 : 12),
                _buildLocationAndReward(location, reward),
                if (post.authorName != null && post.authorName!.isNotEmpty)
                  _buildAuthorSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(PostType postType) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 8,
            vertical: isTablet ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: getTypeColor(postType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                postType.icon,
                size: isTablet ? 16 : 14,
                color: getTypeColor(postType),
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Text(
                postType.label,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w600,
                  color: getTypeColor(postType),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (post.createdAt != null)
          Text(
            TimeUtils.formatTimeAgo(post.createdAt!),
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              color: theme.hintColor,
            ),
          ),
      ],
    );
  }

  Widget _buildTitleAndDescription() {
    return Column(
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
        SizedBox(height: isTablet ? 12 : 8),
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
    );
  }

  Widget _buildImagesSection() {
    return Column(
      children: [
        SizedBox(height: isTablet ? 16 : 12),
        SizedBox(
          height: isTablet ? 80 : 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: post.images.length,
            itemBuilder: (context, imageIndex) {
              return Container(
                margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                width: isTablet ? 80 : 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImageWidget(post.images[imageIndex]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndReward(String location, String? reward) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: isTablet ? 16 : 14,
          color: theme.hintColor,
        ),
        SizedBox(width: isTablet ? 6 : 4),
        Expanded(
          child: Text(
            location,
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              color: theme.hintColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (reward != null && reward.isNotEmpty) ...[
          SizedBox(width: isTablet ? 12 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 10 : 8,
              vertical: isTablet ? 4 : 2,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.card_giftcard_outlined,
                  size: isTablet ? 14 : 12,
                  color: Colors.orange.shade700,
                ),
                SizedBox(width: isTablet ? 4 : 2),
                Text(
                  '${reward}k',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAuthorSection() {
    return Column(
      children: [
        SizedBox(height: isTablet ? 12 : 8),
        Row(
          children: [
            CircleAvatar(
              radius: isTablet ? 12 : 10,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                post.authorName!.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            SizedBox(width: isTablet ? 10 : 8),
            Expanded(
              child: Text(
                post.authorName!,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageWidget(String base64Url) {
    try {
      final base64Str = base64Url.split(',').last;
      final imageBytes = base64Decode(base64Str);
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      );
    } catch (e) {
      return _buildImageErrorWidget();
    }
  }

  Widget _buildImageErrorWidget() {
    return Container(
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: isTablet ? 24 : 20,
        color: theme.hintColor,
      ),
    );
  }
}
