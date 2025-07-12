import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/posts_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/post_card.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/post_skeleton.dart';
import 'dart:convert';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/posts_empty_state.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/posts_pagination.dart';

class PostsListContent extends HookConsumerWidget {
  final PostsListState postsState;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String searchQuery;
  final PostType selectedType;
  final SortOrder selectedSort;
  final Function(Post) onPostTap;
  final VoidCallback onRefresh;
  final VoidCallback onResetFilters;
  final ScrollController scrollController;

  const PostsListContent({
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
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hiển thị skeleton khi đang loading lần đầu (không có dữ liệu)
    if (postsState.isLoading && postsState.posts.isEmpty) {
      return _buildSkeletonContent();
    }

    // Hiển thị empty state khi không có dữ liệu và không loading
    if (postsState.posts.isEmpty && !postsState.isLoading) {
      return _buildEmptyState();
    }

    // Hiển thị danh sách posts (có thể có skeleton cho pagination)
    return _buildPostsList();
  }

  Widget _buildSkeletonContent() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          SizedBox(height: isTablet ? 16 : 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            child: PostSkeletonList(
              isTablet: isTablet,
              colorScheme: colorScheme,
              itemCount: 10,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: PostsEmptyState(
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  searchQuery: searchQuery,
                  selectedType: selectedType,
                  selectedSort: selectedSort,
                  onResetFilters: onResetFilters,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsList() {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // Top spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),

          // Posts List hoặc Skeleton khi loading pagination
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            sliver:
                postsState.isLoadingPage || postsState.isLoading
                    ? SliverToBoxAdapter(
                      child: PostSkeletonList(
                        isTablet: isTablet,
                        colorScheme: colorScheme,
                        itemCount: 10,
                      ),
                    )
                    : SliverList.separated(
                      itemCount: postsState.posts.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          post: postsState.posts[index],
                          isTablet: isTablet,
                          theme: theme,
                          colorScheme: colorScheme,
                          onTap: onPostTap,
                          hasImages: _hasImages,
                          getRewardFromPost: _getRewardFromPost,
                          getLocationFromPost: _getLocationFromPost,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: isTablet ? 8 : 6);
                      },
                    ),
          ),

          // Pagination - luôn hiển thị khi có nhiều trang
          if (postsState.totalPage > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 6),
                child: PostsPagination(
                  state: postsState,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 100 : 80)),
        ],
      ),
    );
  }

  bool _hasImages(Post post) {
    return post.images.isNotEmpty;
  }

  String? _getRewardFromPost(Post post) {
    try {
      if (post.info.isNotEmpty && post.info != '{}') {
        final info = jsonDecode(post.info);

        // For FindLost type, get reward from info
        if (post.type == PostType.findLost.value) {
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
        if (post.type == PostType.foundItem.value) {
          final foundItemInfo = FoundItemInfo.fromJson(info);
          return foundItemInfo.foundLocation.isNotEmpty
              ? foundItemInfo.foundLocation
              : '';
        }

        // For FindLost type
        if (post.type == PostType.findLost.value) {
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
