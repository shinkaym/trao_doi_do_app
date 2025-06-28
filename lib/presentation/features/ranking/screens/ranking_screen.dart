import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/ranking/end_of_list_item.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/ranking/leaderboard_item.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/ranking/current_user_section.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/ranking/loading_item.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/ranking/user_details_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class RankingScreen extends HookConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final rankingState = ref.watch(rankingProvider);

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Load more data function
    void loadMoreData() {
      if (!rankingState.isLoadingMore && rankingState.hasMoreData) {
        ref.read(rankingProvider.notifier).loadMore();
      }
    }

    // Scroll listener
    void onScroll() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        loadMoreData();
      }
    }

    // Handle refresh
    Future<void> handleRefresh() async {
      ref.read(rankingProvider.notifier).refresh();
      if (rankingState.failure == null) {
        context.showSuccessSnackBar('Đã cập nhật bảng xếp hạng');
      }
    }

    // Show user details bottom sheet
    void showUserDetailsBottomSheet() {
      ref.read(myGoodDeedsProvider.notifier).loadMyGoodDeeds();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder:
            (modalContext) => Consumer(
              builder: (context, ref, child) {
                final myGoodDeedsState = ref.watch(myGoodDeedsProvider);
                return UserDetailsBottomSheet(
                  yourInfo: rankingState.yourInfo,
                  goodDeeds: myGoodDeedsState.goodDeeds,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                );
              },
            ),
      );
    }

    // Add scroll listener
    useEffect(() {
      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    // Load initial data
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (rankingState.userRanks.isEmpty && !rankingState.isLoading) {
          ref.read(rankingProvider.notifier).loadRanking(refresh: true);
        }
      });
      return null;
    }, []);

    return SmartScaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: handleRefresh,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Error handling
              if (rankingState.failure != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(isTablet ? 32 : 24),
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.onErrorContainer,
                          size: isTablet ? 24 : 20,
                        ),
                        SizedBox(width: isTablet ? 12 : 8),
                        Expanded(
                          child: Text(
                            'Có lỗi xảy ra khi tải dữ liệu. Vui lòng thử lại.',
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Current User Rank Section
              if (rankingState.yourInfo != null)
                SliverToBoxAdapter(
                  child: CurrentUserSection(
                    yourInfo: rankingState.yourInfo!,
                    yourRank: rankingState.yourRank,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    onDetailsPressed: showUserDetailsBottomSheet,
                  ),
                ),

              // Loading state for initial load
              if (rankingState.isLoading && rankingState.userRanks.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),

              // Leaderboard Header
              if (rankingState.userRanks.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 32 : 24,
                      isTablet ? 24 : 20,
                      isTablet ? 32 : 24,
                      isTablet ? 16 : 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.leaderboard,
                          color: colorScheme.primary,
                          size: isTablet ? 28 : 24,
                        ),
                        SizedBox(width: isTablet ? 12 : 8),
                        Text(
                          'Top người dùng',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Leaderboard List
              if (rankingState.userRanks.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < rankingState.userRanks.length) {
                          return LeaderboardItem(
                            user: rankingState.userRanks[index],
                            displayRank: index + 1,
                            isTablet: isTablet,
                            theme: theme,
                            colorScheme: colorScheme,
                          );
                        } else if (rankingState.isLoadingMore) {
                          return LoadingItem(
                            isTablet: isTablet,
                            colorScheme: colorScheme,
                          );
                        } else if (!rankingState.hasMoreData) {
                          return EndOfListItem(
                            isTablet: isTablet,
                            theme: theme,
                          );
                        }
                        return null;
                      },
                      childCount:
                          rankingState.userRanks.length +
                          (rankingState.isLoadingMore ? 1 : 0) +
                          (!rankingState.hasMoreData ? 1 : 0),
                    ),
                  ),
                ),

              // Bottom padding
              SliverToBoxAdapter(child: SizedBox(height: isTablet ? 32 : 24)),
            ],
          ),
        ),
      ),
    );
  }
}
