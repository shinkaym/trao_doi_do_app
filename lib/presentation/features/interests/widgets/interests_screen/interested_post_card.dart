import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class InterestedPostCard extends StatelessWidget {
  final InterestPost post;
  final CreatePostType postType;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isInterestLoading;
  final Function(String) handlePostTap;
  final Function(int) handleChatTap;
  final Function(int) handleLikeTap;

  const InterestedPostCard({
    super.key,
    required this.post,
    required this.postType,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.isInterestLoading,
    required this.handlePostTap,
    required this.handleChatTap,
    required this.handleLikeTap,
  });

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
              // Header with type and time
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : 8,
                      vertical: isTablet ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: postType.color().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          postType.icon(),
                          size: isTablet ? 16 : 14,
                          color: postType.color(),
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        Text(
                          postType.label(),
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11,
                            fontWeight: FontWeight.w600,
                            color: postType.color(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    TimeUtils.formatTimeAgo(DateTime.parse(post.createdAt)),
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 11,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Post content
              Row(
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
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => handleChatTap(post.interests[0].id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chat_outlined,
                        size: isTablet ? 20 : 18,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  InkWell(
                    onTap:
                        isInterestLoading ? null : () => handleLikeTap(post.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          isInterestLoading
                              ? SizedBox(
                                width: isTablet ? 20 : 18,
                                height: isTablet ? 20 : 18,
                                child: CircularProgressIndicator(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
