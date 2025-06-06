import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/posts_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/post_card.dart';
import 'dart:convert';

import 'package:trao_doi_do_app/presentation/widgets/list_empty_state.dart';
import 'package:trao_doi_do_app/presentation/widgets/pagination.dart';

class PostsListContent extends ConsumerWidget {
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

    return Column(
      children: [
        // Posts List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 12)),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index < postsState.posts.length) {
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
                      }
                      return null;
                    }, childCount: postsState.posts.length),
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

                // Bottom padding for pagination
                SliverToBoxAdapter(
                  child: SizedBox(height: isTablet ? 100 : 80),
                ),
              ],
            ),
          ),
        ),

        // Fixed Pagination at bottom
        if (postsState.totalPage > 1 && postsState.posts.isNotEmpty)
          Pagination(
            state: postsState,
            isTablet: isTablet,
            theme: theme,
            colorScheme: colorScheme,
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
              : 'Không xác định';
        }

        // For FindLost type
        if (post.type == 3) {
          final findLostInfo = FindLostInfo.fromJson(info);
          return findLostInfo.lostLocation.isNotEmpty
              ? findLostInfo.lostLocation
              : 'Không xác định';
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return 'Không xác định';
  }
}
