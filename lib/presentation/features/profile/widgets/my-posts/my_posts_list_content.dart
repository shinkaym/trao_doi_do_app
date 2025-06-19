import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/post_card.dart';
import 'package:trao_doi_do_app/presentation/features/profile/providers/my_posts_provider.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/my-posts/pagination.dart';
import 'dart:convert';
import 'package:trao_doi_do_app/presentation/widgets/list_empty_state.dart';

class MyPostsListContent extends HookConsumerWidget {
  final MyPostsListState postsState;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String searchQuery;
  final PostType selectedType;
  final SortOrder selectedSort;
  final Function(Post) onPostTap;
  final VoidCallback onRefresh;
  final VoidCallback onResetFilters;

  const MyPostsListContent({
    super.key,
    required this.postsState,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.searchQuery,
    required this.selectedType,
    required this.selectedSort,
    required this.onPostTap,
    required this.onRefresh,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (postsState.posts.isEmpty && !postsState.isLoading) {
      return ListEmptyState(
        isTablet: isTablet,
        theme: theme,
        colorScheme: colorScheme,
        searchQuery: searchQuery,
        selectedType: selectedType,
        selectedSort: selectedSort,
        onResetFilters: onResetFilters,
      );
    }

    return Stack(
      children: [
        // Posts List - chiếm toàn bộ màn hình
        RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
                sliver: SliverList.separated(
                  itemCount: postsState.posts.length,
                  itemBuilder: (context, index) {
                    return PostCard(
                      post: postsState.posts[index],
                      isTablet: isTablet,
                      theme: theme,
                      colorScheme: colorScheme,
                      onTap: onPostTap,
                      getTypeColor: _getTypeColor,
                      hasImages: _hasImages,
                      getRewardFromPost: _getRewardFromPost,
                      getLocationFromPost: _getLocationFromPost,
                    );
                  },
                  separatorBuilder: (context, index) {
                    // Khoảng cách giữa các card
                    return SizedBox(height: isTablet ? 8 : 6);
                  },
                ),
              ),

              // Loading indicator
              if (postsState.isLoading || postsState.isLoadingPage)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 32 : 16),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),

              // Bottom padding để tránh pagination che phủ nội dung
              SliverToBoxAdapter(child: SizedBox(height: isTablet ? 120 : 100)),
            ],
          ),
        ),

        // Floating Pagination - positioned ở bottom
        if (postsState.totalPage > 1 && postsState.posts.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              // Tạo gradient fade effect để làm mờ nội dung phía dưới
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Colors.transparent,
                    colorScheme.background.withOpacity(0.3),
                    colorScheme.background.withOpacity(0.7),
                  ],
                ),
              ),
              child: Pagination(
                state: postsState,
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
              ),
            ),
          ),
      ],
    );
  }

  Color _getTypeColor(PostType type) {
    switch (type) {
      case PostType.giveAway:
        return Colors.green;
      case PostType.foundItem:
        return Colors.blue;
      case PostType.findLost:
        return Colors.orange;
      case PostType.freePost:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  bool _hasImages(Post post) {
    return post.images.isNotEmpty;
  }

  String? _getRewardFromPost(Post post) {
    try {
      if (post.info.isNotEmpty && post.info != '{}') {
        final info = jsonDecode(post.info);

        // For FindLost type, get reward from info
        if (post.type == 3) {
          final findLostInfo = FindLostInfo.fromJson(info);
          return findLostInfo.reward.isNotEmpty ? findLostInfo.reward : null;
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  String _getLocationFromPost(Post post) {
    try {
      if (post.info.isNotEmpty && post.info != '{}') {
        final info = jsonDecode(post.info);

        // For FoundItem type
        if (post.type == 2) {
          final foundItemInfo = FoundItemInfo.fromJson(info);
          return foundItemInfo.foundLocation.isNotEmpty
              ? foundItemInfo.foundLocation
              : '';
        }

        // For FindLost type
        if (post.type == 3) {
          final findLostInfo = FindLostInfo.fromJson(info);
          return findLostInfo.lostLocation.isNotEmpty
              ? findLostInfo.lostLocation
              : '';
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return '';
  }
}
