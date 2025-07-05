import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class UserDetailsBottomSheet extends StatelessWidget {
  final UserRank? yourInfo;
  final List<MyGoodDeed> goodDeeds;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const UserDetailsBottomSheet({
    super.key,
    required this.yourInfo,
    required this.goodDeeds,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (yourInfo == null) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            'Không có thông tin chi tiết',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: theme.hintColor,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // Title
          Text(
            'Chi tiết thông tin',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // User info
          Row(
            children: [
              Container(
                width: isTablet ? 80 : 70,
                height: isTablet ? 80 : 70,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: _buildAvatar(yourInfo!.userAvatar, isTablet),
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yourInfo!.userName,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (yourInfo!.major.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        yourInfo!.major,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 32 : 24),

          // Good Deeds List
          Flexible(child: _buildGoodDeedsList(context)),

          SizedBox(height: isTablet ? 32 : 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Đóng',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildGoodDeedsList(BuildContext context) {
    if (goodDeeds.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.volunteer_activism,
              size: isTablet ? 48 : 40,
              color: theme.hintColor.withOpacity(0.5),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Chưa có việc tốt nào được thực hiện',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách việc tốt',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Expanded(
            child: ListView.separated(
              itemCount: goodDeeds.length,
              separatorBuilder:
                  (context, index) => SizedBox(height: isTablet ? 12 : 8),
              itemBuilder: (context, index) {
                final goodDeed = goodDeeds[index];
                return _buildGoodDeedItem(goodDeed);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoodDeedItem(MyGoodDeed goodDeed) {
    final createdAt = DateTime.parse(goodDeed.createdAt);
    final timeAgo = TimeUtils.formatTimeAgo(createdAt);
    final itemsText = _buildItemsText(goodDeed.items);
    final goodDeedType = GoodDeedType.fromValue(goodDeed.goodDeedType);

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type and points
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 10 : 8,
                  vertical: isTablet ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: goodDeedType.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      goodDeedType.icon,
                      size: isTablet ? 14 : 12,
                      color: goodDeedType.color,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      goodDeedType.label,
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: goodDeedType.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 8 : 6,
                  vertical: isTablet ? 4 : 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${goodDeed.goodPoint} điểm',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 8 : 6),

          // Time row
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: isTablet ? 16 : 14,
                color: theme.hintColor,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Items text
          if (itemsText.isNotEmpty) ...[
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              itemsText,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildItemsText(List<GoodDeedItem> items) {
    if (items.isEmpty) return '';

    final itemTexts =
        items.map((item) => '${item.itemName}: ${item.quantity}').toList();
    return itemTexts.join(', ');
  }

  Widget _buildAvatar(String avatarBase64, bool isTablet) {
    if (avatarBase64.isEmpty) {
      return Icon(
        Icons.person,
        size: isTablet ? 35 : 30,
        color: Colors.white.withOpacity(0.7),
      );
    }

    final imageBytes = Base64Utils.decodeImageFromBase64(avatarBase64);
    if (imageBytes == null) {
      return Icon(
        Icons.person,
        size: isTablet ? 35 : 30,
        color: Colors.white.withOpacity(0.7),
      );
    }

    return Image.memory(
      imageBytes,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) => Icon(
            Icons.person,
            size: isTablet ? 35 : 30,
            color: Colors.white.withOpacity(0.7),
          ),
    );
  }
}
