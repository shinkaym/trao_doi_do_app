import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class MyPostCard extends StatelessWidget {
  final Post post;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final void Function(Post) onTap;
  final bool Function(Post) hasImages;
  final String? Function(Post) getRewardFromPost;
  final String Function(Post) getLocationFromPost;
  final void Function(Post)? onToggleStatus;
  final void Function(Post)? onRepost;

  const MyPostCard({
    super.key,
    required this.post,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.onTap,
    required this.hasImages,
    required this.getRewardFromPost,
    required this.getLocationFromPost,
    this.onToggleStatus,
    this.onRepost,
  });

  @override
  Widget build(BuildContext context) {
    final postType = PostType.values.firstWhere(
      (type) => type.value == post.type,
      orElse: () => PostType.all,
    );

    // Lấy status từ post (giả sử post có thuộc tính status)
    final postStatus = PostStatus.fromValue(post.status ?? 0);

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
              _buildHeaderRow(postType, postStatus),
              SizedBox(height: isTablet ? 16 : 12),
              _buildTitleAndDescription(),
              if (hasImages(post)) _buildImagesSection(),
              SizedBox(height: isTablet ? 16 : 12),
              if (location.isNotEmpty)
                _buildLocationAndReward(location, reward),
              _buildStatsSection(),
              _buildActionButtons(postStatus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(PostType postType, PostStatus postStatus) {
    return Row(
      children: [
        // Post Type
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
        SizedBox(width: isTablet ? 12 : 8),
        // Post Status
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 8,
            vertical: isTablet ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: postStatus.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: postStatus.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                postStatus.icon,
                size: isTablet ? 16 : 14,
                color: postStatus.color,
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Text(
                postStatus.label,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w600,
                  color: postStatus.color,
                ),
              ),
            ],
          ),
        ),
        // Spacer để đẩy thời gian sang bên phải
        const Spacer(),
        // Thời gian ở góc phải
        if (post.createdAt != null)
          Text(
            TimeUtils.formatTimeAgo(post.createdAt!),
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
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

  Widget _buildActionButtons(PostStatus postStatus) {
    final List<Widget> buttons = [];

    // Nút Khóa/Mở khóa
    if (postStatus == PostStatus.approved) {
      // Bài đăng đã duyệt -> hiển thị nút khóa
      buttons.add(
        Expanded(
          child: _buildActionButton(
            label: 'Khóa quan tâm',
            icon: Icons.lock,
            backgroundColor: Colors.orange,
            onPressed: () => onToggleStatus?.call(post),
          ),
        ),
      );
    } else if (postStatus == PostStatus.locked) {
      // Bài đăng bị khóa -> hiển thị nút mở khóa
      buttons.add(
        Expanded(
          child: _buildActionButton(
            label: 'Mở khóa quan tâm',
            icon: Icons.lock_open,
            backgroundColor: Colors.green,
            onPressed: () => onToggleStatus?.call(post),
          ),
        ),
      );
    }

    // Nút Đăng lại
    if (postStatus == PostStatus.approved || postStatus == PostStatus.locked) {
      if (buttons.isNotEmpty) {
        buttons.add(SizedBox(width: isTablet ? 16 : 12));
      }
      buttons.add(
        Expanded(
          child: _buildActionButton(
            label: 'Đăng lại',
            icon: Icons.refresh,
            backgroundColor: colorScheme.primary,
            onPressed: () => onRepost?.call(post),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [SizedBox(height: isTablet ? 12 : 8), Row(children: buttons)],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
        backgroundColor: backgroundColor,
        elevation: 1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isTablet ? 18 : 16, color: Colors.white),
          SizedBox(width: isTablet ? 8 : 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
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
