import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/context_extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';

class InterestedUsersSection extends StatefulWidget {
  final InterestPost post;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Function(int) handleChatTap;

  const InterestedUsersSection({
    super.key,
    required this.post,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.handleChatTap,
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
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

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
                return Container(
                  margin: EdgeInsets.only(bottom: widget.isTablet ? 8 : 6),
                  padding: EdgeInsets.all(widget.isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: widget.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: widget.isTablet ? 16 : 14,
                        backgroundColor: widget.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        child: _buildInterestAvatar(
                          interest,
                          isTablet,
                          colorScheme,
                        ),
                      ),
                      SizedBox(width: widget.isTablet ? 12 : 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              interest.userName,
                              style: TextStyle(
                                fontSize: widget.isTablet ? 14 : 13,
                                fontWeight: FontWeight.w600,
                                color: widget.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Quan tâm ${TimeUtils.formatTimeAgo(DateTime.parse(interest.createdAt))}',
                              style: TextStyle(
                                fontSize: widget.isTablet ? 12 : 11,
                                color: widget.theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => widget.handleChatTap(interest.id),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: EdgeInsets.all(widget.isTablet ? 8 : 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: widget.colorScheme.outline.withOpacity(
                                0.3,
                              ),
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
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildInterestAvatar(
  Interest interest,
  bool isTablet,
  ColorScheme colorScheme,
) {
  final radius = isTablet ? 16.0 : 14.0;

  if (interest.userAvatar.isNotEmpty) {
    final imageBytes = Base64Utils.decodeImageFromBase64(interest.userAvatar);

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
    backgroundColor: colorScheme.primary,
    child: Icon(Icons.person, color: Colors.white, size: isTablet ? 16 : 14),
  );
}
