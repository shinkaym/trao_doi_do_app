import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/params/interests_query.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/interests_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/pagination.dart';
import 'package:trao_doi_do_app/presentation/providers/interest_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes
    _tabController.addListener(_onTabChanged);

    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadInitialData();
        _isInitialized = true;
      }
    });
  }

  void _loadInitialData() {
    // Load data for current tab only
    if (_tabController.index == 0) {
      ref
          .read(interestedPostsProvider.notifier)
          .loadInterests(
            newQuery: const InterestsQuery(
              type: 1,
              sort: 'createdAt',
              order: 'DESC',
            ),
            refresh: true,
          );
    } else {
      ref
          .read(postsWithInterestsProvider.notifier)
          .loadInterests(
            newQuery: const InterestsQuery(
              type: 2,
              sort: 'createdAt',
              order: 'DESC',
            ),
            refresh: true,
          );
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;

    final currentIndex = _tabController.index;

    if (currentIndex == 0) {
      // Tab "Tôi quan tâm"
      final state = ref.read(interestedPostsProvider);
      if (state.interests.isEmpty && !state.isLoading) {
        ref
            .read(interestedPostsProvider.notifier)
            .loadInterests(
              newQuery: const InterestsQuery(
                type: 1,
                sort: 'createdAt',
                order: 'DESC',
              ),
              refresh: true,
            );
      }
    } else {
      // Tab "Quan tâm tôi"
      final state = ref.read(postsWithInterestsProvider);
      if (state.interests.isEmpty && !state.isLoading) {
        ref
            .read(postsWithInterestsProvider.notifier)
            .loadInterests(
              newQuery: const InterestsQuery(
                type: 2,
                sort: 'createdAt',
                order: 'DESC',
              ),
              refresh: true,
            );
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handlePostTap(String slug) {
    context.pushNamed('post-detail', pathParameters: {'slug': slug});
  }

  void _handleChatTap(int interestId) {
    context.pushNamed(
      'interest-chat',
      pathParameters: {'interestId': interestId.toString()},
    );
  }

  // Cập nhật method _handleLikeTap để thực hiện toggle interest
  Future<void> _handleLikeTap(int postId, WidgetRef ref) async {
    // Thực hiện cancel interest vì đây là tab "Tôi quan tâm"
    await ref.read(interestProvider.notifier).cancelInterest(postId);
    
    // Lắng nghe kết quả
    final interestState = ref.read(interestProvider);
    
    if (interestState.result != null) {
      // Thành công - refresh lại danh sách
      ref.read(interestedPostsProvider.notifier).refresh();
      
      // Clear messages sau khi xử lý
      ref.read(interestProvider.notifier).clearMessages();
    } else if (interestState.failure != null) {
      // Thất bại - hiển thị lỗi
      context.showErrorSnackBar(interestState.failure!.message);
      
      // Clear messages sau khi xử lý
      ref.read(interestProvider.notifier).clearMessages();
    }
  }

  void _onSearch(String value) {
    final currentTab = _tabController.index;
    final searchValue = value.isEmpty ? null : value;

    if (currentTab == 0) {
      ref.read(interestedPostsProvider.notifier).search(searchValue);
    } else {
      ref.read(postsWithInterestsProvider.notifier).search(searchValue);
    }
  }

  void _onSortFilter(String field, String order) {
    final currentTab = _tabController.index;

    if (currentTab == 0) {
      ref.read(interestedPostsProvider.notifier).sortInterests(field, order);
    } else {
      ref.read(postsWithInterestsProvider.notifier).sortInterests(field, order);
    }
  }

  void _resetFilters() {
    _searchController.clear();
    final currentTab = _tabController.index;

    if (currentTab == 0) {
      ref.read(interestedPostsProvider.notifier).search(null);
      ref
          .read(interestedPostsProvider.notifier)
          .sortInterests('createdAt', 'DESC');
    } else {
      ref.read(postsWithInterestsProvider.notifier).search(null);
      ref
          .read(postsWithInterestsProvider.notifier)
          .sortInterests('createdAt', 'DESC');
    }
  }

  InterestsListState _getCurrentState() {
    final currentTab = _tabController.index;
    if (currentTab == 0) {
      return ref.watch(interestedPostsProvider);
    } else {
      return ref.watch(postsWithInterestsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final state = _getCurrentState();

    // Lắng nghe interest state để xử lý loading và error
    ref.listen<InterestState>(interestProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        // Đã hoàn thành action
        if (next.result != null) {
          // Thành công - refresh lại danh sách
          if (_tabController.index == 0) {
            ref.read(interestedPostsProvider.notifier).refresh();
          }
        }
      }
    });

    return SmartScaffold(
      title: 'Quan tâm',
      appBarType: AppBarType.standard,
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(isTablet, theme, colorScheme, state),

          // Tab Bar
          _buildTabBar(isTablet, theme, colorScheme),

          // Tab Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final currentTab = _tabController.index;
                if (currentTab == 0) {
                  ref.read(interestedPostsProvider.notifier).refresh();
                } else {
                  ref.read(postsWithInterestsProvider.notifier).refresh();
                }
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInterestedPostsTab(isTablet, theme, colorScheme, ref),
                  _buildPostsWithInterestsTab(
                    isTablet,
                    theme,
                    colorScheme,
                    ref,
                  ),
                ],
              ),
            ),
          ),

          // Pagination
          if (state.totalPage > 1)
            Pagination(
              state: state,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
              currentTabIndex: _tabController.index, 
            ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterSection(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    InterestsListState state,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bài đăng quan tâm...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 16 : 12,
              ),
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Sort Options
          SingleChildScrollView(
            // scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  selected: state.query.order == 'DESC',
                  onSelected: (selected) {
                    if (selected) _onSortFilter('createdAt', 'DESC');
                  },
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: isTablet ? 18 : 16),
                      SizedBox(width: isTablet ? 6 : 4),
                      const Text('Mới nhất'),
                    ],
                  ),
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.primary,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                ChoiceChip(
                  selected: state.query.order == 'ASC',
                  onSelected: (selected) {
                    if (selected) _onSortFilter('createdAt', 'ASC');
                  },
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: isTablet ? 18 : 16),
                      SizedBox(width: isTablet ? 6 : 4),
                      const Text('Cũ nhất'),
                    ],
                  ),
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.primary,
                ),
              ],
            ),
          ),

          // Results Count
          if (state.interests.isNotEmpty) ...[
            SizedBox(height: isTablet ? 12 : 8),
            Row(
              children: [
                Text(
                  'Tìm thấy ${state.interests.length} kết quả',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isTablet, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, size: isTablet ? 20 : 18),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Tôi quan tâm',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: isTablet ? 20 : 18),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Quan tâm tôi',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        indicatorColor: colorScheme.primary,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      ),
    );
  }

  Widget _buildInterestedPostsTab(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(interestedPostsProvider);
        final interestState = ref.watch(interestProvider);

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
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
          return _buildEmptyState(
            isTablet,
            theme,
            colorScheme,
            'Chưa có bài đăng quan tâm',
            'Khám phá và quan tâm các bài đăng thú vị',
            Icons.favorite_border,
            showResetButton:
                _searchController.text.isNotEmpty ||
                state.query.order != 'DESC',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16,
            vertical: isTablet ? 24 : 16,
          ),
          itemCount: state.interests.length,
          itemBuilder: (context, index) {
            final post = state.interests[index];
            final postType = CreatePostType.fromValue(post.type);
            return _buildInterestedPostCard(
              post,
              postType,
              isTablet,
              theme,
              colorScheme,
              ref,
              interestState.isLoading,
            );
          },
        );
      },
    );
  }

  Widget _buildPostsWithInterestsTab(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(postsWithInterestsProvider);

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
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
                    ref.read(postsWithInterestsProvider.notifier).refresh();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state.interests.isEmpty) {
          return _buildEmptyState(
            isTablet,
            theme,
            colorScheme,
            'Chưa có bài đăng được quan tâm',
            'Tạo bài đăng để nhận được sự quan tâm từ cộng đồng',
            Icons.post_add,
            showResetButton:
                _searchController.text.isNotEmpty ||
                state.query.order != 'DESC',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16,
            vertical: isTablet ? 24 : 16,
          ),
          itemCount: state.interests.length,
          itemBuilder: (context, index) {
            final post = state.interests[index];
            final postType = CreatePostType.fromValue(post.type);
            return _buildPostWithInterestsCard(
              post,
              postType,
              isTablet,
              theme,
              colorScheme,
              ref,
            );
          },
        );
      },
    );
  }

Widget _buildInterestedPostCard(
  InterestPost post,
  CreatePostType? postType,
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  WidgetRef ref,
  bool isInterestLoading,
) {
  return Container(
    margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        onTap: () => _handlePostTap(post.slug),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and time
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : 8,
                      vertical: isTablet ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: postType?.color.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          postType?.icon ?? Icons.article,
                          size: isTablet ? 16 : 14,
                          color: postType?.color ?? Colors.grey,
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        Text(
                          postType?.label ?? 'Khác',
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11,
                            fontWeight: FontWeight.w600,
                            color: postType?.color ?? Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    TimeUtils.formatTimeAgo(DateTime.parse(post.updatedAt)),
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 11,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Post content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        if (post.description.isNotEmpty)
                          Text(
                            post.description,
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 13,
                              color: colorScheme.onSurface.withOpacity(0.8),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Action buttons (chat, like) với loading state
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _handleChatTap(post.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chat_outlined,
                        size: isTablet ? 20 : 18,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  InkWell(
                    onTap: isInterestLoading ? null : () => _handleLikeTap(post.id, ref),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isInterestLoading
                          ? SizedBox(
                              width: isTablet ? 20 : 18,
                              height: isTablet ? 20 : 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : Icon(
                              Icons.favorite,
                              size: isTablet ? 20 : 18,
                              color: Colors.red,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildPostWithInterestsCard(
    InterestPost post,
    CreatePostType? postType,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          onTap: () => _handlePostTap(post.slug),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            postType?.color.withOpacity(0.1) ??
                            Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            postType?.icon ?? Icons.article,
                            size: isTablet ? 16 : 14,
                            color: postType?.color ?? Colors.grey,
                          ),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(
                            postType?.label ?? 'Khác',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 11,
                              fontWeight: FontWeight.w600,
                              color: postType?.color ?? Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      TimeUtils.formatTimeAgo(DateTime.parse(post.updatedAt)),
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Post info
                Row(
                  children: [
                    // Thumbnail
                    // Title
                    Expanded(
                      child: Text(
                        post.title,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),

                if (post.description.isNotEmpty)
                  Text(
                    post.description,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      color: colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: isTablet ? 16 : 12),

                // Interested users count
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: isTablet ? 16 : 14,
                        color: Colors.red,
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        '${post.interests.length} người quan tâm',
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                if (post.interests.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 12 : 8),

                  // List of interested users
                  ...post.interests
                      .take(3)
                      .map(
                        (user) => Container(
                          margin: EdgeInsets.only(bottom: isTablet ? 8 : 6),
                          padding: EdgeInsets.all(isTablet ? 12 : 8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: isTablet ? 16 : 14,
                                backgroundColor: colorScheme.primary
                                    .withOpacity(0.1),
                                child:
                                    user.userAvatar.isNotEmpty
                                        ? ClipOval(
                                          child: Image.network(
                                            user.userAvatar,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Icon(
                                                Icons.person,
                                                size: isTablet ? 16 : 14,
                                                color: colorScheme.primary,
                                              );
                                            },
                                          ),
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: isTablet ? 16 : 14,
                                          color: colorScheme.primary,
                                        ),
                              ),
                              SizedBox(width: isTablet ? 12 : 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.userName,
                                      style: TextStyle(
                                        fontSize: isTablet ? 14 : 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Quan tâm ${TimeUtils.formatTimeAgo(DateTime.parse(user.createdAt))}',
                                      style: TextStyle(
                                        fontSize: isTablet ? 12 : 11,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => _handleChatTap(user.id),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: EdgeInsets.all(isTablet ? 8 : 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorScheme.outline.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.chat_outlined,
                                    size: isTablet ? 16 : 14,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                  if (post.interests.length > 3)
                    Text(
                      'và ${post.interests.length - 3} người khác',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: theme.hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String subtitle,
    IconData icon, {
    bool showResetButton = false,
  }) {
    // Kiểm tra xem có đang áp dụng bộ lọc không
    final hasActiveFilters =
        _searchController.text.isNotEmpty ||
        _getCurrentState().query.order != 'DESC';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isTablet ? 80 : 64, color: theme.hintColor),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            hasActiveFilters
                ? 'Không tìm thấy kết quả phù hợp với bộ lọc'
                : subtitle,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),

          // Hiển thị nút đặt lại bộ lọc nếu có bộ lọc đang áp dụng
          if (hasActiveFilters) ...[
            SizedBox(height: isTablet ? 24 : 20),
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: Icon(Icons.refresh, size: isTablet ? 20 : 18),
              label: Text(
                'Đặt lại bộ lọc',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
