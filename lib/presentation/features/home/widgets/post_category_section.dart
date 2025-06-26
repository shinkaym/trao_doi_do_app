import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/usecases/params/post_query.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/post_card.dart';

class PostCategorySection extends HookConsumerWidget {
  final PostType postType;
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const PostCategorySection({
    super.key,
    required this.postType,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(postsProviderFamily(postType));

    useEffect(() {
      if (postsState.posts.isEmpty && !postsState.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(postsProviderFamily(postType).notifier)
              .loadPosts(
                newQuery: PostsQuery(
                  type: postType.value,
                  limit: 5,
                  page: 1,
                  sort: 'createdAt',
                  order: 'DESC',
                ),
                refresh: true,
              );
        });
      }
      return null;
    }, [postType]);

    // Nếu không có bài viết nào, không hiển thị section
    if (postsState.posts.isEmpty && !postsState.isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with padding only on mobile
          _CategoryHeader(
            postType: postType,
            isTablet: isTablet,
            colorScheme: colorScheme,
            onCreatePost: () => _navigateToCreatePost(context, postType),
            onViewAll: () => _navigateToSearch(context, postType),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Posts Slideshow
          if (postsState.isLoading)
            _LoadingSlideshow(isTablet: isTablet)
          else if (postsState.posts.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
              child: _PostsSlideshow(
                posts: postsState.posts.take(4).toList(), // Tối đa 4 bài
                postType: postType,
                isTablet: isTablet,
                colorScheme: colorScheme,
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToCreatePost(BuildContext context, PostType postType) {
    context.pushNamed(RouteNames.createPost, extra: {'type': postType});
  }

  void _navigateToSearch(BuildContext context, PostType postType) {
    context.pushNamed(RouteNames.posts, extra: {'type': postType});
  }
}

class _CategoryHeader extends StatelessWidget {
  final PostType postType;
  final bool isTablet;
  final ColorScheme colorScheme;
  final VoidCallback onCreatePost;
  final VoidCallback onViewAll;

  const _CategoryHeader({
    required this.postType,
    required this.isTablet,
    required this.colorScheme,
    required this.onCreatePost,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          // Icon với background tròn - Updated style
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: postType.color.withOpacity(0.15),
              // shape: BoxShape.circle, // Changed from BorderRadius.circular(8) to circle
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              postType.icon,
              color: postType.color,
              size: isTablet ? 16 : 14,
            ),
          ),

          SizedBox(width: isTablet ? 12 : 8),

          // Title only - Updated font size to match
          Expanded(
            child: Text(
              postType.label,
              style: TextStyle(
                fontSize:
                    isTablet
                        ? 18
                        : 16, // Increased from 18:16 to match college links
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                // letterSpacing: 0.5,
              ),
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Create button
              _ActionButton(
                onPressed: onCreatePost,
                icon: Icons.add_circle_outline,
                color: postType.color,
                tooltip: 'Tạo ${postType.label}',
                isTablet: isTablet,
                isPrimary: true,
              ),

              SizedBox(width: isTablet ? 8 : 6),

              // View all button
              _ActionButton(
                onPressed: onViewAll,
                icon: Icons.arrow_forward_ios,
                color: colorScheme.primary,
                tooltip: 'Xem tất cả',
                isTablet: isTablet,
                isPrimary: false,
                text: 'Xem tất cả',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final String tooltip;
  final bool isTablet;
  final bool isPrimary;
  final String? text;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.isTablet,
    required this.isPrimary,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text != null && !isPrimary) {
      // Text button style for "Xem tất cả"
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 10,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text!,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: isTablet ? 4 : 3),
                Icon(icon, size: isTablet ? 14 : 12, color: color),
              ],
            ),
          ),
        ),
      );
    }

    // Icon button style for create button
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: EdgeInsets.all(isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: isPrimary ? color.withOpacity(0.12) : Colors.transparent,
              shape: BoxShape.circle,
              border:
                  isPrimary
                      ? Border.all(color: color.withOpacity(0.3), width: 1)
                      : null,
            ),
            child: Icon(icon, color: color, size: isTablet ? 20 : 18),
          ),
        ),
      ),
    );
  }
}

class _LoadingSlideshow extends StatelessWidget {
  final bool isTablet;

  const _LoadingSlideshow({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isTablet ? 180 : 150,
      child: CarouselSlider.builder(
        itemCount: 4,
        itemBuilder: (context, index, realIndex) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.zero, // Loại bỏ margin để full width
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        options: CarouselOptions(
          height: isTablet ? 180 : 150,
          viewportFraction: 1.0, // Full width như banner
          enableInfiniteScroll: false,
          enlargeCenterPage: false,
          autoPlay: false,
        ),
      ),
    );
  }
}

class _PostsSlideshow extends StatefulWidget {
  final List<Post> posts;
  final PostType postType;
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _PostsSlideshow({
    required this.posts,
    required this.postType,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
  });

  @override
  State<_PostsSlideshow> createState() => _PostsSlideshowState();
}

class _PostsSlideshowState extends State<_PostsSlideshow> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel
        CarouselSlider.builder(
          itemCount: widget.posts.length,
          itemBuilder: (context, index, realIndex) {
            final post = widget.posts[index];
            return Container(
              width: MediaQuery.of(context).size.width,
              child: PostCard(
                post: post,
                postType: widget.postType,
                isTablet: widget.isTablet,
                colorScheme: widget.colorScheme,
                theme: widget.theme,
                onTap: (post) {
                  context.pushNamed(
                    'post-detail',
                    pathParameters: {'slug': post.slug.toString()},
                  );
                },
              ),
            );
          },
          options: CarouselOptions(
            height: widget.isTablet ? 180 : 150,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: false, // Tắt việc phóng to slide ở giữa
            viewportFraction: 1.0, // Full width như banner
            enableInfiniteScroll: widget.posts.length > 1,
            pauseAutoPlayOnTouch: true,
            pauseAutoPlayOnManualNavigate: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),

        // Page indicators (chỉ hiển thị khi có > 1 bài viết)
        if (widget.posts.length > 1) ...[
          const SizedBox(height: 12),
          _buildPageIndicator(),
        ],
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          widget.posts.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                // Có thể thêm controller để jump to page nếu cần
              },
              child: Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentIndex == entry.key
                          ? widget.colorScheme.primary
                          : widget.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
    );
  }
}
