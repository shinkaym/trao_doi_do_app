import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/pagination.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/skeleton_loading.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/empty_state.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/unified_interest_post_card.dart';

class InterestedPostsTab extends ConsumerWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Function(String) handlePostTap;
  final Function(int) handleChatTap;
  final Function(int) handleLikeTap;
  final TextEditingController searchController;
  final VoidCallback resetFilters;
  final ScrollController scrollController;

  const InterestedPostsTab({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.handlePostTap,
    required this.handleChatTap,
    required this.handleLikeTap,
    required this.searchController,
    required this.resetFilters,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interestedPostsProvider);
    final interestState = ref.watch(interestProvider);

    if (state.isLoading) {
      return SkeletonLoading(
        isTablet: isTablet,
        theme: theme,
        colorScheme: colorScheme,
      );
    }

    if (state.failure != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.failure!.message,
              style: TextStyle(fontSize: 14, color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(interestedPostsProvider.notifier).refresh();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state.interests.isEmpty) {
      return EmptyState(
        isTablet: isTablet,
        theme: theme,
        colorScheme: colorScheme,
        title: 'Chưa có bài đăng quan tâm',
        subtitle: 'Khám phá và quan tâm các bài đăng thú vị',
        icon: Icons.favorite_border,
        sharedSearchController: searchController,
        resetFilters: resetFilters,
      );
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
          sliver: SliverList.separated(
            separatorBuilder:
                (context, index) => SizedBox(height: isTablet ? 8 : 6),
            itemCount: state.interests.length,
            itemBuilder: (context, index) {
              final post = state.interests[index];
              final postType = CreatePostType.fromValue(post.type);
              final authState = ref.read(authProvider);

              return UnifiedInterestPostCard.interestedPost(
                post: post,
                postType: postType,
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
                handlePostTap: handlePostTap,
                handleChatTap: handleChatTap,
                handleLikeTap: handleLikeTap,
                isInterestLoading: interestState.isLoading,
                authUserId: authState.user?.id,
              );
            },
          ),
        ),
        // Pagination được thêm vào cuối danh sách
        if (state.totalPage > 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Pagination(
                state: state,
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
                currentTabIndex: 0,
              ),
            ),
          ),
      ],
    );
  }
}
