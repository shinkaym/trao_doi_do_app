import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/user_avatar_for_list.dart';

class UserInterestListItem extends StatefulWidget {
  final PostInterest interest;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const UserInterestListItem({
    super.key,
    required this.interest,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  State<UserInterestListItem> createState() => _UserInterestListItemState();
}

class _UserInterestListItemState extends State<UserInterestListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            },
            onTapUp: (_) {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            onTapCancel: () {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: widget.isTablet ? 4 : 2),
              padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color:
                    _isHovered
                        ? widget.colorScheme.surfaceVariant.withOpacity(0.3)
                        : widget.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow:
                    _isHovered
                        ? [
                          BoxShadow(
                            color: widget.colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                children: [
                  // Avatar with border
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.8),
                          Colors.red.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: UserAvatarForList(
                      interest: widget.interest,
                      isTablet: widget.isTablet,
                      colorScheme: widget.colorScheme,
                    ),
                  ),
                  SizedBox(width: widget.isTablet ? 16 : 12),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.interest.userName,
                          style: widget.theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: widget.isTablet ? 4 : 2),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: widget.isTablet ? 14 : 12,
                              color: Colors.red.withOpacity(0.7),
                            ),
                            SizedBox(width: widget.isTablet ? 6 : 4),
                            Expanded(
                              child: Text(
                                'Đã quan tâm bài đăng',
                                style: widget.theme.textTheme.bodySmall
                                    ?.copyWith(
                                      color:
                                          widget.colorScheme.onSurfaceVariant,
                                      fontSize: widget.isTablet ? 12 : 11,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action icon
                  Container(
                    padding: EdgeInsets.all(widget.isTablet ? 8 : 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: widget.isTablet ? 18 : 16,
                      color: Colors.red.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
