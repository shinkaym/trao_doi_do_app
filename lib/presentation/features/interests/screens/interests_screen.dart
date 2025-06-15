import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interest_query.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/interests_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/pagination.dart';
import 'package:trao_doi_do_app/presentation/models/interest_chat_transaction_data.dart';
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
    final searchController = useTextEditingController();
    final isInitialized = useRef(false);

    // Get current state based on active tab
    InterestsListState getCurrentState() {
      final currentTab = tabController.index;
      if (currentTab == 0) {
        return ref.watch(interestedPostsProvider);
      } else {
        return ref.watch(postsWithInterestsProvider);
      }
    }

    // Load initial data
    void loadInitialData() {
      if (tabController.index == 0) {
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

    // Load data for specific tab
    void loadDataForTab(int tabIndex) {
      final searchValue =
          searchController.text.isEmpty ? null : searchController.text;
      final currentState = getCurrentState();

      if (tabIndex == 0) {
        ref
            .read(interestedPostsProvider.notifier)
            .loadInterests(
              newQuery: InterestsQuery(
                type: 1,
                sort: currentState.query.sort,
                order: currentState.query.order,
                search: searchValue,
              ),
              refresh: true,
            );
      } else {
        ref
            .read(postsWithInterestsProvider.notifier)
            .loadInterests(
              newQuery: InterestsQuery(
                type: 2,
                sort: currentState.query.sort,
                order: currentState.query.order,
                search: searchValue,
              ),
              refresh: true,
            );
      }
    }

    // Apply current filters to tab
    void applyCurrentFiltersToTab(int tabIndex) {
      final searchValue =
          searchController.text.isEmpty ? null : searchController.text;
      final currentState = getCurrentState();

      if (tabIndex == 0) {
        if (searchValue != null) {
          ref.read(interestedPostsProvider.notifier).search(searchValue);
        }
        ref
            .read(interestedPostsProvider.notifier)
            .sortInterests(currentState.query.sort, currentState.query.order);
      } else {
        if (searchValue != null) {
          ref.read(postsWithInterestsProvider.notifier).search(searchValue);
        }
        ref
            .read(postsWithInterestsProvider.notifier)
            .sortInterests(currentState.query.sort, currentState.query.order);
      }
    }

    // Handle tab changes
    void onTabChanged() {
      if (!tabController.indexIsChanging) return;

      final currentIndex = tabController.index;

      if (currentIndex == 0) {
        final state = ref.read(interestedPostsProvider);
        if (state.interests.isEmpty && !state.isLoading) {
          loadDataForTab(0);
        } else {
          applyCurrentFiltersToTab(0);
        }
      } else {
        final state = ref.read(postsWithInterestsProvider);
        if (state.interests.isEmpty && !state.isLoading) {
          loadDataForTab(1);
        } else {
          applyCurrentFiltersToTab(1);
        }
      }
    }

    // Handle search
    void onSearch(String value) {
      final currentTab = tabController.index;
      final searchValue = value.trim().isEmpty ? null : value.trim();

      if (currentTab == 0) {
        if (searchValue == null) {
          ref
              .read(interestedPostsProvider.notifier)
              .loadInterests(
                newQuery: InterestsQuery(
                  type: 1,
                  sort: ref.read(interestedPostsProvider).query.sort,
                  order: ref.read(interestedPostsProvider).query.order,
                  search: null,
                ),
                refresh: true,
              );
        } else {
          ref.read(interestedPostsProvider.notifier).search(searchValue);
        }
      } else {
        if (searchValue == null) {
          ref
              .read(postsWithInterestsProvider.notifier)
              .loadInterests(
                newQuery: InterestsQuery(
                  type: 2,
                  sort: ref.read(postsWithInterestsProvider).query.sort,
                  order: ref.read(postsWithInterestsProvider).query.order,
                  search: null,
                ),
                refresh: true,
              );
        } else {
          ref.read(postsWithInterestsProvider.notifier).search(searchValue);
        }
      }
    }

    // Handle sort/filter
    void onSortFilter(String field, String order) {
      final currentTab = tabController.index;

      if (currentTab == 0) {
        ref.read(interestedPostsProvider.notifier).sortInterests(field, order);
      } else {
        ref
            .read(postsWithInterestsProvider.notifier)
            .sortInterests(field, order);
      }
    }

    // Reset filters
    // Reset filters - FIXED VERSION
    void resetFilters() {
      searchController.clear();
      final currentTab = tabController.index;

      if (currentTab == 0) {
        // Reset về trạng thái mặc định với query mới
        ref
            .read(interestedPostsProvider.notifier)
            .loadInterests(
              newQuery: const InterestsQuery(
                type: 1,
                sort: 'createdAt',
                order: 'DESC',
                search: null,
              ),
              refresh: true,
            );
      } else {
        // Reset về trạng thái mặc định với query mới
        ref
            .read(postsWithInterestsProvider.notifier)
            .loadInterests(
              newQuery: const InterestsQuery(
                type: 2,
                sort: 'createdAt',
                order: 'DESC',
                search: null,
              ),
              refresh: true,
            );
      }
    }

    // Handle post tap
    void handlePostTap(String slug) {
      context.pushNamed('post-detail', pathParameters: {'slug': slug});
    }

    // Handle chat tap
    void handleChatTap(
      int interestId,
      bool isPostOwner,
      List<InterestItem> items,
      InterestPost post,
    ) {
      context.pushNamed(
        'interest-chat',
        pathParameters: {'interestId': interestId.toString()},
        extra: InterestChatTransactionData(
          post: post,
          isPostOwner: isPostOwner,
          items: items,
        ),
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
        title: 'Quan tâm',
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
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(
            isTablet,
            theme,
            colorScheme,
            state,
            searchController,
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
                    searchController,
                    resetFilters,
                  ),
                  _buildPostsWithInterestsTab(
                    isTablet,
                    theme,
                    colorScheme,
                    ref,
                    handlePostTap,
                    handleChatTap,
                    searchController,
                    resetFilters,
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
              currentTabIndex: tabController.index,
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
  InterestsListState state,
  TextEditingController searchController,
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
          controller: searchController,
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bài đăng quan tâm...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                searchController.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        searchController.clear();
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
              selected: state.query.order == 'DESC',
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
                        state.query.order == 'DESC'
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                  ),
                  SizedBox(width: isTablet ? 6 : 4),
                  Text(
                    'Mới nhất',
                    style: TextStyle(
                      color:
                          state.query.order == 'DESC'
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
              selected: state.query.order == 'ASC',
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
                        state.query.order == 'ASC'
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                  ),

                  SizedBox(width: isTablet ? 6 : 4),
                  Text(
                    'Cũ nhất',
                    style: TextStyle(
                      color:
                          state.query.order == 'ASC'
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
  Function(int, bool, List<InterestItem>, InterestPost) handleChatTap,
  Function(int) handleLikeTap,
  TextEditingController searchController, // Thêm tham số
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
          searchController, // Sử dụng searchController từ widget chính
          state,
          resetFilters, // Sử dụng hàm resetFilters từ widget chính
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
            interestState.isLoading,
            handlePostTap,
            handleChatTap,
            handleLikeTap,
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
  Function(String) handlePostTap,
  Function(int, bool, List<InterestItem>, InterestPost) handleChatTap,
  TextEditingController searchController, // Thêm tham số
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
          searchController, // Sử dụng searchController từ widget chính
          state,
          resetFilters, // Sử dụng hàm resetFilters từ widget chính
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
            handlePostTap,
            handleChatTap,
          );
        },
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
  Function(int, bool, List<InterestItem>, InterestPost) handleChatTap,
  Function(int) handleLikeTap,
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
                    onTap:
                        () => handleChatTap(
                          post.interests[0].id,
                          false,
                          post.items,
                          post,
                        ),
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
  Function(int, bool, List<InterestItem>, InterestPost) handleChatTap,
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
    ),
  );
}

// Separate widget for interested users section with collapse functionality
class _InterestedUsersSection extends StatefulWidget {
  final InterestPost post;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Function(int, bool, List<InterestItem>, InterestPost) handleChatTap;

  const _InterestedUsersSection({
    required this.post,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.handleChatTap,
  });

  @override
  State<_InterestedUsersSection> createState() =>
      _InterestedUsersSectionState();
}

class _InterestedUsersSectionState extends State<_InterestedUsersSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Interest count header with tap to expand
        InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? 12 : 8,
              vertical: widget.isTablet ? 8 : 6,
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
                  size: widget.isTablet ? 16 : 14,
                  color: Colors.red,
                ),
                SizedBox(width: widget.isTablet ? 6 : 4),
                Text(
                  '${widget.post.interests.length} người quan tâm',
                  style: TextStyle(
                    fontSize: widget.isTablet ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: widget.isTablet ? 8 : 6),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: widget.isTablet ? 18 : 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated collapse content
        SizeTransition(
          sizeFactor: _animation,
          child: Container(
            margin: EdgeInsets.only(top: widget.isTablet ? 12 : 8),
            constraints: BoxConstraints(
              maxHeight: 200, // Limit height to show max 3 users initially
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.post.interests.length,
              itemBuilder: (context, index) {
                final interest = widget.post.interests[index];
                return Container(
                  margin: EdgeInsets.only(bottom: widget.isTablet ? 8 : 6),
                  padding: EdgeInsets.all(widget.isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: widget.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: widget.isTablet ? 16 : 14,
                        backgroundColor: widget.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        child: _buildInterestAvatar(
                          interest,
                          isTablet,
                          colorScheme,
                        ),
                      ),
                      SizedBox(width: widget.isTablet ? 12 : 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              interest.userName,
                              style: TextStyle(
                                fontSize: widget.isTablet ? 14 : 13,
                                fontWeight: FontWeight.w600,
                                color: widget.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Quan tâm ${TimeUtils.formatTimeAgo(DateTime.parse(interest.createdAt))}',
                              style: TextStyle(
                                fontSize: widget.isTablet ? 12 : 11,
                                color: widget.theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap:
                            () => widget.handleChatTap(
                              interest.id,
                              true,
                              widget.post.items,
                              widget.post,
                            ),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: EdgeInsets.all(widget.isTablet ? 8 : 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: widget.colorScheme.outline.withOpacity(
                                0.3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.chat_outlined,
                            size: widget.isTablet ? 16 : 14,
                            color: widget.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildInterestAvatar(
  Interest interest,
  bool isTablet,
  ColorScheme colorScheme,
) {
  final radius = isTablet ? 16.0 : 14.0;

  if (interest.userAvatar.isNotEmpty) {
    final imageBytes = Base64Utils.decodeImageFromBase64(interest.userAvatar);

    if (imageBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(imageBytes),
      );
    }
  }

  // Fallback về icon
  return CircleAvatar(
    radius: radius,
    backgroundColor: colorScheme.primary,
    child: Icon(Icons.person, color: Colors.white, size: isTablet ? 16 : 14),
  );
}

// Helper function to build the interested users section
Widget _buildInterestedUsersSection(
  InterestPost post,
  bool isTablet,
  ThemeData theme,
  ColorScheme colorScheme,
  Function(int, bool, List<InterestItem>, InterestPost) handleChatTap,
) {
  return _InterestedUsersSection(
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
  TextEditingController searchController,
  InterestsListState state,
  VoidCallback resetFilters,
) {
  // Kiểm tra xem có đang áp dụng bộ lọc không
  final hasActiveFilters =
      searchController.text.isNotEmpty || state.query.order != 'DESC';

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
