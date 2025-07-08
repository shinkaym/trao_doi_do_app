import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/user_interest_list_item.dart';

class AllUsersBottomSheet extends StatefulWidget {
  final List<PostInterest> interests;

  const AllUsersBottomSheet({super.key, required this.interests});

  @override
  State<AllUsersBottomSheet> createState() => _AllUsersBottomSheetState();
}

class _AllUsersBottomSheetState extends State<AllUsersBottomSheet>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeSheet() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: _closeSheet,
              child: Container(
                color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
              ),
            ),

            // Bottom Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value * 400),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: mediaQuery.size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        margin: EdgeInsets.only(top: isTablet ? 16 : 12),
                        width: isTablet ? 48 : 40,
                        height: isTablet ? 5 : 4,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      // Header
                      _buildHeader(isTablet, theme, colorScheme),

                      // Users list
                      Flexible(
                        child:
                            widget.interests.isEmpty
                                ? _buildEmptyState(isTablet, theme, colorScheme)
                                : ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 24 : 20,
                                    vertical: isTablet ? 16 : 12,
                                  ),
                                  itemCount: widget.interests.length,
                                  separatorBuilder:
                                      (_, __) => Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: isTablet ? 8 : 6,
                                        ),
                                        child: Divider(
                                          color: colorScheme.outline
                                              .withOpacity(0.1),
                                          height: 1,
                                          thickness: 0.5,
                                        ),
                                      ),
                                  itemBuilder: (context, index) {
                                    final interest = widget.interests[index];
                                    return UserInterestListItem(
                                      interest: interest,
                                      isTablet: isTablet,
                                      theme: theme,
                                      colorScheme: colorScheme,
                                    );
                                  },
                                ),
                      ),

                      SizedBox(height: isTablet ? 24 : 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isTablet, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.red,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Người quan tâm',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${widget.interests.length} người đã quan tâm bài đăng này',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Count badge
          IconButton(
            onPressed: _closeSheet,
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
              size: isTablet ? 22 : 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surface.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 48 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: isTablet ? 48 : 40,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Text(
            'Chưa có ai quan tâm',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Bài đăng của bạn chưa có người nào quan tâm',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
