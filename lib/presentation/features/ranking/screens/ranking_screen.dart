import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

// Providers for state management
final isLoadingProvider = StateProvider<bool>((ref) => false);
final hasMoreDataProvider = StateProvider<bool>((ref) => true);

// Mock current user data provider
final currentUserRankProvider = Provider<Map<String, dynamic>>(
  (ref) => {
    'rank': 15,
    'name': 'Nguyễn Văn An',
    'points': 850,
    'goodDeeds': 42,
    'avatar': '',
  },
);

// Initial leaderboard data provider
final initialLeaderboardProvider = Provider<List<Map<String, dynamic>>>(
  (ref) => [
    {
      'rank': 1,
      'name': 'Trần Thị Hương',
      'points': 2150,
      'goodDeeds': 89,
      'avatar': '',
    },
    {
      'rank': 2,
      'name': 'Lê Văn Minh',
      'points': 1980,
      'goodDeeds': 76,
      'avatar': '',
    },
    {
      'rank': 3,
      'name': 'Phạm Thu Lan',
      'points': 1850,
      'goodDeeds': 71,
      'avatar': '',
    },
    {
      'rank': 4,
      'name': 'Hoàng Đức Nam',
      'points': 1720,
      'goodDeeds': 68,
      'avatar': '',
    },
    {
      'rank': 5,
      'name': 'Vũ Thị Mai',
      'points': 1650,
      'goodDeeds': 65,
      'avatar': '',
    },
    {
      'rank': 6,
      'name': 'Đỗ Văn Tuấn',
      'points': 1580,
      'goodDeeds': 62,
      'avatar': '',
    },
    {
      'rank': 7,
      'name': 'Ngô Thị Linh',
      'points': 1520,
      'goodDeeds': 59,
      'avatar': '',
    },
    {
      'rank': 8,
      'name': 'Bùi Văn Hùng',
      'points': 1480,
      'goodDeeds': 57,
      'avatar': '',
    },
    {
      'rank': 9,
      'name': 'Lý Thị Nga',
      'points': 1420,
      'goodDeeds': 54,
      'avatar': '',
    },
    {
      'rank': 10,
      'name': 'Trương Văn Đức',
      'points': 1380,
      'goodDeeds': 52,
      'avatar': '',
    },
  ],
);

// Leaderboard data state provider
final leaderboardDataProvider =
    StateNotifierProvider<LeaderboardNotifier, List<Map<String, dynamic>>>((
      ref,
    ) {
      return LeaderboardNotifier(ref.read(initialLeaderboardProvider));
    });

class LeaderboardNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  LeaderboardNotifier(List<Map<String, dynamic>> initialData)
    : super(initialData);

  void addData(List<Map<String, dynamic>> newData) {
    state = [...state, ...newData];
  }

  void reset(List<Map<String, dynamic>> data) {
    state = data;
  }
}

class RankingScreen extends HookConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final isLoading = ref.watch(isLoadingProvider);
    final hasMoreData = ref.watch(hasMoreDataProvider);
    final leaderboardData = ref.watch(leaderboardDataProvider);
    final currentUserRank = ref.watch(currentUserRankProvider);

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Load more data function
    Future<void> loadMoreData() async {
      if (isLoading || !hasMoreData) return;

      ref.read(isLoadingProvider.notifier).state = true;

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock loading more data
      List<Map<String, dynamic>> newData = [];
      int currentLength = leaderboardData.length;

      for (int i = 1; i <= 10; i++) {
        if (currentLength + i > 50) {
          // Simulate end of data at 50 users
          ref.read(hasMoreDataProvider.notifier).state = false;
          break;
        }

        newData.add({
          'rank': currentLength + i,
          'name': 'Người dùng ${currentLength + i}',
          'points': 1380 - (currentLength + i - 10) * 20,
          'goodDeeds': 52 - (currentLength + i - 10) * 1,
          'avatar': '',
        });
      }

      ref.read(leaderboardDataProvider.notifier).addData(newData);
      ref.read(isLoadingProvider.notifier).state = false;
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
      ref.read(isLoadingProvider.notifier).state = true;
      await Future.delayed(const Duration(seconds: 1));
      ref.read(isLoadingProvider.notifier).state = false;
      context.showSuccessSnackBar('Đã cập nhật bảng xếp hạng');
    }

    // Add scroll listener
    useEffect(() {
      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return SmartScaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: handleRefresh,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Current User Rank Section
              SliverToBoxAdapter(
                child: _buildCurrentUserSection(
                  currentUserRank,
                  isTablet,
                  theme,
                  colorScheme,
                ),
              ),

              // Leaderboard Header
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
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < leaderboardData.length) {
                        return _buildLeaderboardItem(
                          leaderboardData[index],
                          isTablet,
                          theme,
                          colorScheme,
                        );
                      } else if (isLoading) {
                        return _buildLoadingItem(isTablet, colorScheme);
                      } else if (!hasMoreData) {
                        return _buildEndOfListItem(isTablet, theme);
                      }
                      return null;
                    },
                    childCount:
                        leaderboardData.length +
                        (isLoading ? 1 : 0) +
                        (!hasMoreData ? 1 : 0),
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

  Widget _buildCurrentUserSection(
    Map<String, dynamic> currentUserRank,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 32 : 24),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.person_pin,
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                'Xếp hạng của bạn',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          Row(
            children: [
              // Avatar and Rank
              Container(
                width: isTablet ? 80 : 70,
                height: isTablet ? 80 : 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child:
                          currentUserRank['avatar']!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: Image.network(
                                  currentUserRank['avatar']!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        size: isTablet ? 40 : 35,
                                        color: Colors.white,
                                      ),
                                ),
                              )
                              : Icon(
                                Icons.person,
                                size: isTablet ? 40 : 35,
                                color: Colors.white,
                              ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 8 : 6,
                          vertical: isTablet ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${currentUserRank['rank']}',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isTablet ? 20 : 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUserRank['name'],
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 6),

                    Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.star,
                          value: '${currentUserRank['points']}',
                          label: 'điểm',
                          isTablet: isTablet,
                        ),
                        SizedBox(width: isTablet ? 20 : 16),
                        _buildStatItem(
                          icon: Icons.favorite,
                          value: '${currentUserRank['goodDeeds']}',
                          label: 'việc tốt',
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isTablet,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: isTablet ? 18 : 16,
        ),
        SizedBox(width: isTablet ? 6 : 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    Map<String, dynamic> user,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final rank = user['rank'] as int;
    final isTopFive = rank <= 5;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color:
            isTopFive
                ? colorScheme.primaryContainer.withOpacity(0.1)
                : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isTopFive
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outline.withOpacity(0.2),
          width: isTopFive ? 2 : 1,
        ),
        boxShadow:
            isTopFive
                ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
      ),
      child: Row(
        children: [
          // Rank Icon/Number
          Container(
            width: isTablet ? 50 : 45,
            height: isTablet ? 50 : 45,
            decoration: BoxDecoration(
              color: _getRankColor(rank, colorScheme),
              borderRadius: BorderRadius.circular(25),
              boxShadow:
                  isTopFive
                      ? [
                        BoxShadow(
                          color: _getRankColor(
                            rank,
                            colorScheme,
                          ).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Center(
              child:
                  isTopFive
                      ? Icon(
                        _getRankIcon(rank),
                        color: Colors.white,
                        size: isTablet ? 24 : 20,
                      )
                      : Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),

          SizedBox(width: isTablet ? 16 : 12),

          // Avatar
          Container(
            width: isTablet ? 50 : 45,
            height: isTablet ? 50 : 45,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child:
                user['avatar']!.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        user['avatar']!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: isTablet ? 24 : 20,
                              color: theme.hintColor,
                            ),
                      ),
                    )
                    : Icon(
                      Icons.person,
                      size: isTablet ? 24 : 20,
                      color: theme.hintColor,
                    ),
          ),

          SizedBox(width: isTablet ? 16 : 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: isTablet ? 14 : 12,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(width: isTablet ? 4 : 3),
                    Text(
                      '${user['goodDeeds']} việc tốt',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Points
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 10,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: isTablet ? 16 : 14,
                  color: Colors.amber.shade600,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  '${user['points']}',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingItem(bool isTablet, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 50 : 45,
            height: isTablet ? 50 : 45,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Container(
            width: isTablet ? 50 : 45,
            height: isTablet ? 50 : 45,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: isTablet ? 16 : 14,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Container(
                  width: 100,
                  height: isTablet ? 12 : 10,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: isTablet ? 60 : 50,
            height: isTablet ? 30 : 25,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfListItem(bool isTablet, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: isTablet ? 48 : 40,
            color: theme.hintColor.withOpacity(0.5),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Đã hiển thị tất cả người dùng',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank, ColorScheme colorScheme) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      case 4:
      case 5:
        return colorScheme.primary;
      default:
        return colorScheme.secondary;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      case 4:
        return Icons.looks_4;
      case 5:
        return Icons.looks_5;
      default:
        return Icons.person;
    }
  }
}
