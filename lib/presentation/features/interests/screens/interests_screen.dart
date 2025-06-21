import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interest_query.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/interests_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/interested_user_section.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/pagination.dart';
import 'package:trao_doi_do_app/presentation/widgets/login_prompt.dart';
import 'package:trao_doi_do_app/presentation/providers/interest_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class InterestsScreen extends HookConsumerWidget {
  const InterestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Hooks for state management
    final tabController = useTabController(initialLength: 2);
    final isInitialized = useRef(false);

    final sharedSearchController = useTextEditingController();
    final sharedSortField = useState('createdAt');
    final sharedSortOrder = useState('DESC');

    // Get current state based on active tab
    InterestsListState getCurrentState() {
      final currentTab = tabController.index;
      if (currentTab == 0) {
        return ref.watch(interestedPostsProvider);
      } else {
        return ref.watch(postsWithInterestsProvider);
      }
    }

    void applySharedFiltersToCurrentTab() {
      final currentTab = tabController.index;
      final searchValue =
          sharedSearchController.text.isEmpty
              ? null
              : sharedSearchController.text;

      final query = InterestsQuery(
        type: currentTab == 0 ? 1 : 2,
        sort: sharedSortField.value,
        order: sharedSortOrder.value,
        search: searchValue,
      );

      if (currentTab == 0) {
        ref
            .read(interestedPostsProvider.notifier)
            .loadInterests(newQuery: query, refresh: true);
      } else {
        ref
            .read(postsWithInterestsProvider.notifier)
            .loadInterests(newQuery: query, refresh: true);
      }
    }

    // Load initial data
    void loadInitialData() {
      applySharedFiltersToCurrentTab();
    }

    // Handle tab changes
    void onTabChanged() {
      if (tabController.indexIsChanging) return;
      applySharedFiltersToCurrentTab();
    }

    // Handle search
    void onSearch(String value) {
      applySharedFiltersToCurrentTab();
    }

    // Handle sort/filter
    void onSortFilter(String field, String order) {
      sharedSortField.value = field;
      sharedSortOrder.value = order;
      applySharedFiltersToCurrentTab();
    }

    // Reset filters
    // Reset filters - FIXED VERSION
    void resetFilters() {
      sharedSearchController.clear();
      sharedSortField.value = 'createdAt';
      sharedSortOrder.value = 'DESC';
      applySharedFiltersToCurrentTab();
    }

    // Handle post tap
    void handlePostTap(String slug) {
      context.pushNamed('post-detail', pathParameters: {'slug': slug});
    }

    // Handle chat tap
    void handleChatTap(int interestId) {
      context.pushNamed(
        'interest-chat',
        pathParameters: {'interestId': interestId.toString()},
      );
    }

    // Handle like tap
    Future<void> handleLikeTap(int postId) async {
      await ref.read(interestProvider.notifier).cancelInterest(postId);

      final interestState = ref.read(interestProvider);

      if (interestState.result != null) {
        ref.read(interestedPostsProvider.notifier).refresh();
        ref.read(interestProvider.notifier).clearMessages();
      } else if (interestState.failure != null) {
        context.showErrorSnackBar(interestState.failure!.message);
        ref.read(interestProvider.notifier).clearMessages();
      }
    }

    // Initialize data on first build
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isInitialized.value) {
          loadInitialData();
          isInitialized.value = true;
        }
      });
      return null;
    }, []);

    // Listen to tab changes
    useEffect(() {
      tabController.addListener(onTabChanged);
      return () => tabController.removeListener(onTabChanged);
    }, [tabController]);

    // Listen to interest state changes
    ref.listen<InterestState>(interestProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (next.result != null && tabController.index == 0) {
          ref.read(interestedPostsProvider.notifier).refresh();
        }
      }
    });

    final authState = ref.watch(authProvider);
    final state = getCurrentState();

    if (!authState.isLoggedIn) {
      return SmartScaffold(
        appBarType: AppBarType.standard,
        body: LoginPrompt(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          title: 'Đăng nhập để xem danh sách bài đăng đã và được quan tâm',
          description:
              'Bạn cần đăng nhập để có thể xem danh sách bài đăng đã và được quan tâm. Đăng nhập ngay để trải nghiệm đầy đủ tính năng.',
          guestInfoText: '',
        ),
      );
    }

    return SmartScaffold(
      title: 'Quan tâm',
      appBarType: AppBarType.standard,
      body: Stack(
        children: [
          Column(
            children: [
              // Search and Filter Section
              _buildSearchFilterSection(
                isTablet,
                theme,
                colorScheme,
                sharedSortOrder.value,
                sharedSearchController,
                onSearch,
                onSortFilter,
              ),

              // Tab Bar
              _buildTabBar(isTablet, theme, colorScheme, tabController),

              // Tab Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final currentTab = tabController.index;
                    if (currentTab == 0) {
                      ref.read(interestedPostsProvider.notifier).refresh();
                    } else {
                      ref.read(postsWithInterestsProvider.notifier).refresh();
                    }
                  },
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      _buildInterestedPostsTab(
                        isTablet,
                        theme,
                        colorScheme,
                        ref,
                        handlePostTap,
                        handleChatTap,
                        handleLikeTap,
                        sharedSearchController,
                        resetFilters,
                      ),
                      _buildPostsWithInterestsTab(
                        isTablet,
                        theme,
                        colorScheme,
                        ref,
                        handlePostTap,
                        handleChatTap,
                        sharedSearchController,
                        resetFilters,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Pagination
          if (state.totalPage > 1)
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
                  state: state,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  currentTabIndex: tabController.index,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildSearchFilterSection(
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  String currentSortOrder,
  TextEditingController sharedSearchController,
  Function(String) onSearch,
  Function(String, String) onSortFilter,
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
          controller: sharedSearchController,
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bài đăng quan tâm...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                sharedSearchController.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        sharedSearchController.clear();
                        onSearch('');
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
              vertical: isTablet ? 6 : 4,
            ),
          ),
        ),

        SizedBox(height: isTablet ? 16 : 12),

        // Sort Options
        Row(
          children: [
            ChoiceChip(
              selected: currentSortOrder == 'DESC',
              onSelected: (selected) {
                if (selected) onSortFilter('createdAt', 'DESC');
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: isTablet ? 18 : 16,
                    color:
                        currentSortOrder == 'DESC'
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                  ),
                  SizedBox(width: isTablet ? 6 : 4),
                  Text(
                    'Mới nhất',
                    style: TextStyle(
                      color:
                          currentSortOrder == 'DESC'
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.secondary,
            ),
            SizedBox(width: isTablet ? 12 : 8),
            ChoiceChip(
              selected: currentSortOrder == 'ASC',
              onSelected: (selected) {
                if (selected) onSortFilter('createdAt', 'ASC');
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: isTablet ? 18 : 16,
                    color:
                        currentSortOrder == 'ASC'
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                  ),
                  SizedBox(width: isTablet ? 6 : 4),
                  Text(
                    'Cũ nhất',
                    style: TextStyle(
                      color:
                          currentSortOrder == 'ASC'
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.secondary,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTabBar(
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  TabController tabController,
) {
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
      controller: tabController,
      tabs: [
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, size: isTablet ? 20 : 18),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Đang quan tâm',
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
                'Quan tâm',
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
  Function(String) handlePostTap,
  Function(int) handleChatTap,
  Function(int) handleLikeTap,
  TextEditingController sharedSearchController, // Thêm tham số
  VoidCallback resetFilters,
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
          sharedSearchController, // Sử dụng sharedSearchController từ widget chính
          resetFilters, // Sử dụng hàm resetFilters từ widget chính
        );
      }

      return CustomScrollView(
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
                return _buildInterestedPostCard(
                  post,
                  postType,
                  isTablet,
                  theme,
                  colorScheme,
                  interestState.isLoading,
                  handlePostTap,
                  handleChatTap,
                  handleLikeTap,
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildPostsWithInterestsTab(
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  WidgetRef ref,
  Function(String) handlePostTap,
  Function(int) handleChatTap,
  TextEditingController sharedSearchController, // Thêm tham số
  VoidCallback resetFilters,
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
          sharedSearchController, // Sử dụng sharedSearchController từ widget chính
          resetFilters, // Sử dụng hàm resetFilters từ widget chính
        );
      }

      return CustomScrollView(
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
                return _buildPostWithInterestsCard(
                  post,
                  postType,
                  isTablet,
                  theme,
                  colorScheme,
                  handlePostTap,
                  handleChatTap,
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildInterestedPostCard(
  InterestPost post,
  CreatePostType postType,
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  bool isInterestLoading,
  Function(String) handlePostTap,
  Function(int) handleChatTap,
  Function(int) handleLikeTap,
) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      onTap: () => handlePostTap(post.slug),
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
                    color: postType.color().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        postType.icon(),
                        size: isTablet ? 16 : 14,
                        color: postType.color(),
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        postType.label(),
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 11,
                          fontWeight: FontWeight.w600,
                          color: postType.color(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  TimeUtils.formatTimeAgo(DateTime.parse(post.createdAt)),
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
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => handleChatTap(post.interests[0].id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
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
                  onTap:
                      isInterestLoading ? null : () => handleLikeTap(post.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        isInterestLoading
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
  );
}

Widget _buildPostWithInterestsCard(
  InterestPost post,
  CreatePostType postType,
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  Function(String) handlePostTap,
  Function(int) handleChatTap,
) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      onTap: () => handlePostTap(post.slug),
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
                    color: postType.color().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        postType.icon(),
                        size: isTablet ? 16 : 14,
                        color: postType.color(),
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        postType.label(),
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 11,
                          fontWeight: FontWeight.w600,
                          color: postType.color(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  TimeUtils.formatTimeAgo(DateTime.parse(post.createdAt)),
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
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Interested users section with collapse
            if (post.interests.isNotEmpty)
              _buildInterestedUsersSection(
                post,
                isTablet,
                theme,
                colorScheme,
                handleChatTap,
              ),
          ],
        ),
      ),
    ),
  );
}

// Separate widget for interested users section with collapse functionality

// Helper function to build the interested users section
Widget _buildInterestedUsersSection(
  InterestPost post,
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  Function(int) handleChatTap,
) {
  return InterestedUsersSection(
    post: post,
    isTablet: isTablet,
    theme: theme,
    colorScheme: colorScheme,
    handleChatTap: handleChatTap,
  );
}

Widget _buildEmptyState(
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  String title,
  String subtitle,
  IconData icon,
  TextEditingController sharedSearchController,
  VoidCallback resetFilters,
) {
  final hasActiveFilters = sharedSearchController.text.isNotEmpty;

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
            onPressed: resetFilters,
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
