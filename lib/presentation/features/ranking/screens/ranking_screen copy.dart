import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';
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
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder:
            (modalContext) => _buildUserDetailsBottomSheet(
              modalContext,
              rankingState.yourInfo,
              isTablet,
              theme,
              colorScheme,
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
                  child: _buildCurrentUserSection(
                    rankingState.yourInfo!,
                    rankingState.yourRank,
                    isTablet,
                    theme,
                    colorScheme,
                    showUserDetailsBottomSheet,
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
                          return _buildLeaderboardItem(
                            rankingState.userRanks[index],
                            index + 1, // rank position in the list
                            isTablet,
                            theme,
                            colorScheme,
                          );
                        } else if (rankingState.isLoadingMore) {
                          return _buildLoadingItem(isTablet, colorScheme);
                        } else if (!rankingState.hasMoreData) {
                          return _buildEndOfListItem(isTablet, theme);
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

  Widget _buildCurrentUserSection(
    UserRank yourInfo,
    int yourRank,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    VoidCallback onDetailsPressed,
  ) {
    final totalGoodDeeds = yourInfo.goodDeeds.fold(
      0,
      (sum, deed) => sum + deed.goodDeedCount,
    );

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
              const Spacer(),
              TextButton.icon(
                onPressed: onDetailsPressed,
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: isTablet ? 20 : 18,
                ),
                label: Text(
                  'Chi tiết',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          Row(
            children: [
              // Avatar and Rank - SỬA AVATAR THÀNH HÌNH TRÒN
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
                    // SỬA: Thêm ClipRRect để avatar thành hình tròn
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          35,
                        ), // Radius nhỏ hơn container để tránh bị cắt border
                        child: _buildAvatar(yourInfo.userAvatar, isTablet),
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
                          '#$yourRank',
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

              // User Info - SỬA LAYOUT THÀNH 2 CỘT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yourInfo.userName,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1, // CHỈ 1 HÀNG
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (yourInfo.major.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        yourInfo.major,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1, // CHỈ 1 HÀNG
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: isTablet ? 8 : 6),

                    // SỬA: Layout stats thành 2 cột ngang không xuống dòng
                    Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.star,
                          value: '${yourInfo.goodPoint}',
                          label: 'điểm',
                          isTablet: isTablet,
                        ),
                        SizedBox(width: isTablet ? 20 : 16),
                        _buildStatItem(
                          icon: Icons.favorite,
                          value: '$totalGoodDeeds',
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
        Text(
          '$value $label',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    UserRank user,
    int displayRank,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isTopFive = displayRank <= 5;
    final totalGoodDeeds = user.goodDeeds.fold(
      0,
      (sum, deed) => sum + deed.goodDeedCount,
    );

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
              color: _getRankColor(displayRank, colorScheme),
              borderRadius: BorderRadius.circular(25),
              boxShadow:
                  isTopFive
                      ? [
                        BoxShadow(
                          color: _getRankColor(
                            displayRank,
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
                        _getRankIcon(displayRank),
                        color: Colors.white,
                        size: isTablet ? 24 : 20,
                      )
                      : Text(
                        '$displayRank',
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildAvatar(user.userAvatar, isTablet),
            ),
          ),

          SizedBox(width: isTablet ? 16 : 12),

          // User Info - SỬA: TÊN CHỈ 1 HÀNG VÀ MAJOR CHỈ 1 HÀNG
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1, // CHỈ 1 HÀNG
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.major.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 2 : 1),
                  Text(
                    user.major,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      color: theme.hintColor,
                    ),
                    maxLines: 1, // CHỈ 1 HÀNG
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: isTablet ? 6 : 4),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: isTablet ? 14 : 12,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(width: isTablet ? 4 : 3),
                    Expanded(
                      child: Text(
                        '$totalGoodDeeds việc tốt',
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 11,
                          color: theme.hintColor,
                        ),
                        maxLines: 1, // CHỈ 1 HÀNG
                        overflow: TextOverflow.ellipsis,
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
                  '${user.goodPoint}',
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

  Widget _buildAvatar(String avatarBase64, bool isTablet) {
    if (avatarBase64.isEmpty) {
      return Icon(
        Icons.person,
        size: isTablet ? 35 : 30,
        color: Colors.white.withOpacity(0.7),
      );
    }

    final imageBytes = Base64Utils.decodeImageFromBase64(avatarBase64);
    if (imageBytes == null) {
      return Icon(
        Icons.person,
        size: isTablet ? 35 : 30,
        color: Colors.white.withOpacity(0.7),
      );
    }

    return Image.memory(
      imageBytes,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) => Icon(
            Icons.person,
            size: isTablet ? 35 : 30,
            color: Colors.white.withOpacity(0.7),
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

  Widget _buildUserDetailsBottomSheet(
    BuildContext context,
    UserRank? yourInfo,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (yourInfo == null) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            'Không có thông tin chi tiết',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: theme.hintColor,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // Title
          Text(
            'Chi tiết thông tin',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // User info
          Row(
            children: [
              Container(
                width: isTablet ? 80 : 70,
                height: isTablet ? 80 : 70,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: _buildAvatar(yourInfo.userAvatar, isTablet),
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yourInfo.userName,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (yourInfo.major.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        yourInfo.major,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 32 : 24),

          // Placeholder content
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.construction,
                  size: isTablet ? 48 : 40,
                  color: theme.hintColor.withOpacity(0.5),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Nội dung chi tiết đang được phát triển',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Text(
                  'Sẽ hiển thị thông tin chi tiết về các việc tốt và điểm số',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: theme.hintColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 32 : 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Đóng',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
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
