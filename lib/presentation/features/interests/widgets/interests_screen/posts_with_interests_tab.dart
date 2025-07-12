import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/pagination.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/skeleton_loading.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/empty_state.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/unified_interest_post_card.dart';

class PostsWithInterestsTab extends ConsumerWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Function(String) handlePostTap;
  final Function(int) handleChatTap;
  final TextEditingController searchController;
  final VoidCallback resetFilters;
  final ScrollController scrollController;
  final VoidCallback onRefresh;

  const PostsWithInterestsTab({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.handlePostTap,
    required this.handleChatTap,
    required this.searchController,
    required this.resetFilters,
    required this.onRefresh,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postsWithInterestsProvider);

    // Hiển thị skeleton khi đang loading lần đầu (không có dữ liệu)
    if (state.isLoading && state.interests.isEmpty) {
      return _buildSkeletonContent();
    }

    // Hiển thị error state
    if (state.failure != null) {
      return _buildErrorState(ref);
    }

    // Hiển thị empty state khi không có dữ liệu và không loading
    if (state.interests.isEmpty && !state.isLoading) {
      return _buildEmptyState();
    }

    // Hiển thị danh sách interests (có thể có skeleton cho pagination)
    return _buildInterestsList(ref);
  }

  Widget _buildSkeletonContent() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          SizedBox(height: isTablet ? 16 : 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            child: SkeletonLoading(
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
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
            ref.watch(postsWithInterestsProvider).failure!.message,
            style: TextStyle(fontSize: 14, color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(postsWithInterestsProvider.notifier).refresh();
            },
            child: const Text('Thử lại'),
          ),
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
                child: EmptyState(
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  title: 'Chưa có bài đăng quan tâm',
                  subtitle: 'Khám phá và quan tâm các bài đăng thú vị',
                  icon: Icons.favorite_border,
                  sharedSearchController: searchController,
                  resetFilters: resetFilters,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInterestsList(WidgetRef ref) {
    final state = ref.watch(postsWithInterestsProvider);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Top spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),

          // Interests List hoặc Skeleton khi loading pagination
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            sliver:
                state.isLoading || state.isLoadingPage
                    ? SliverToBoxAdapter(
                      child: SkeletonLoading(
                        isTablet: isTablet,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                    )
                    : SliverList.separated(
                      itemCount: state.interests.length,
                      itemBuilder: (context, index) {
                        final post = state.interests[index];
                        final postType = PostType.fromValue(post.type);
                        final authState = ref.read(authProvider);

                        return UnifiedInterestPostCard.postWithInterests(
                          post: post,
                          postType: postType,
                          isTablet: isTablet,
                          theme: theme,
                          colorScheme: colorScheme,
                          handlePostTap: handlePostTap,
                          handleChatTap: handleChatTap,
                          authUserId: authState.user?.id,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: isTablet ? 8 : 6);
                      },
                    ),
          ),

          // Pagination - luôn hiển thị khi có nhiều trang
          if (state.totalPage > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 6),
                child: Pagination(
                  state: state,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  currentTabIndex: 1,
                ),
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 100 : 80)),
        ],
      ),
    );
  }
}
