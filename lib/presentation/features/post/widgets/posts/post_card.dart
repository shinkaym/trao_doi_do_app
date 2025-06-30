import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final void Function(Post) onTap;
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

    return Card(
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
              SizedBox(height: isTablet ? 12 : 8),
              if (post.authorName != null && post.authorName!.isNotEmpty)
                _buildAuthorSection(),
              SizedBox(height: isTablet ? 16 : 12),
              _buildTitleAndDescription(),
              if (hasImages(post)) _buildImagesSection(),
              SizedBox(height: isTablet ? 16 : 12),
              // Hiển thị thông tin đặc biệt theo loại post
              if (postType == PostType.campaign)
                _buildCampaignInfo()
              else if (location.isNotEmpty)
                _buildLocationAndReward(location, reward),
              _buildStatsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(PostType postType) {
    return Container(
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
          Icon(postType.icon, size: isTablet ? 16 : 14, color: postType.color),
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
    );
  }

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
                post.authorName!,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (post.createdAt != null) ...[
                SizedBox(height: 2),
                Text(
                  TimeUtils.formatTimeAgo(post.createdAt!),
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ],
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
          height: isTablet ? 120 : 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: post.images.length,
            itemBuilder: (context, imageIndex) {
              return Container(
                margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                width: isTablet ? 120 : 100,
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

  // Widget mới để hiển thị thông tin campaign
  Widget _buildCampaignInfo() {
    try {
      final campaignInfo = CampaignInfo.fromJson(jsonDecode(post.info));

      return Column(
        children: [
          // Thời gian campaign
          if (campaignInfo.startDate.isNotEmpty ||
              campaignInfo.endDate.isNotEmpty)
            _buildCampaignInfoRow(
              Icons.calendar_today_outlined,
              _formatCampaignDates(
                campaignInfo.startDate,
                campaignInfo.endDate,
              ),
              Colors.blue.shade600,
            ),

          // Địa điểm
          if (campaignInfo.location.isNotEmpty)
            _buildCampaignInfoRow(
              Icons.location_on_outlined,
              campaignInfo.location,
              Colors.green.shade600,
            ),

          // Tổ chức
          if (campaignInfo.organizer.isNotEmpty)
            _buildCampaignInfoRow(
              Icons.group_outlined,
              'Tổ chức bởi: ${campaignInfo.organizer}',
              Colors.orange.shade600,
            ),

          SizedBox(height: isTablet ? 12 : 8),
        ],
      );
    } catch (e) {
      // Nếu không parse được info, hiển thị location thông thường
      final location = getLocationFromPost(post);
      if (location.isNotEmpty) {
        return _buildLocationAndReward(location, null);
      }
      return const SizedBox.shrink();
    }
  }

  Widget _buildCampaignInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 6 : 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: isTablet ? 16 : 14, color: color),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isTablet ? 13 : 11,
                color: colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCampaignDates(String startDate, String endDate) {
    try {
      DateTime? start = startDate.isNotEmpty ? DateTime.parse(startDate) : null;
      DateTime? end = endDate.isNotEmpty ? DateTime.parse(endDate) : null;

      if (start != null && end != null) {
        return '${TimeUtils.formatAbsolute(start)} - ${TimeUtils.formatAbsolute(end)}';
      } else if (start != null) {
        return 'Từ: ${TimeUtils.formatAbsolute(start)}';
      } else if (end != null) {
        return 'Đến: ${TimeUtils.formatAbsolute(end)}';
      }
      return '';
    } catch (e) {
      // Fallback nếu không parse được DateTime
      if (startDate.isNotEmpty && endDate.isNotEmpty) {
        return '$startDate - $endDate';
      } else if (startDate.isNotEmpty) {
        return 'Từ: $startDate';
      } else if (endDate.isNotEmpty) {
        return 'Đến: $endDate';
      }
      return '';
    }
  }

  Widget _buildLocationAndReward(String location, String? reward) {
    return Column(
      children: [
        Row(
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
                      reward,
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
        ),
        SizedBox(height: isTablet ? 12 : 8),
      ],
    );
  }

  Widget _buildStatsSection() {
    final List<Widget> stats = [];

    // Số lượt yêu thích
    if (post.interestCount != null && post.interestCount! > 0) {
      stats.add(
        _buildStatItem(
          Icons.favorite_outline,
          post.interestCount.toString(),
          Colors.red.shade600,
        ),
      );
    }

    // Số lượng món đồ hiện tại / tổng số
    if (post.itemCount != null && post.itemCount! > 0) {
      String itemText;
      Color itemColor = Colors.blue.shade600;

      if (post.currentItemCount != null) {
        if (post.currentItemCount == 0) {
          itemText = 'Hết đồ';
          itemColor = Colors.grey.shade600; // Đổi màu khi hết hàng
        } else {
          itemText = '${post.currentItemCount}/${post.itemCount}';
        }
      } else {
        itemText = post.itemCount.toString();
      }

      stats.add(
        _buildStatItem(Icons.inventory_2_outlined, itemText, itemColor),
      );
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              stats[i],
              if (i < stats.length - 1) SizedBox(width: isTablet ? 16 : 12),
            ],
          ],
        ),
        SizedBox(height: isTablet ? 12 : 8),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 8,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 14 : 12, color: color),
          SizedBox(width: isTablet ? 4 : 3),
          Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorAvatar() {
    final radius = isTablet ? 16.0 : 14.0;

    if (post.authorAvatar != null && post.authorAvatar!.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(post.authorAvatar!);

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

  Widget _buildImageWidget(String base64Url) {
    final imageBytes = Base64Utils.decodeImageFromBase64(base64Url);

    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      );
    }

    return _buildImageErrorWidget();
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
