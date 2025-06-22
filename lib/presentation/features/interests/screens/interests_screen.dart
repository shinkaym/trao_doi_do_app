import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interest_query.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/search_filter_section.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/interests_tab_bar.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/interested_posts_tab.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/posts_with_interests_tab.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/scroll_to_top_button.dart';
import 'package:trao_doi_do_app/presentation/widgets/login_prompt.dart';
import 'package:trao_doi_do_app/presentation/providers/interest_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

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
    final scrollController = useScrollController();

    final sharedSearchController = useTextEditingController();
    final sharedSortField = useState('createdAt');
    final sharedSortOrder = useState('DESC');

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

    // Load initial data for both tabs
    void loadInitialData() {
      final searchValue =
          sharedSearchController.text.isEmpty
              ? null
              : sharedSearchController.text;

      final interestedQuery = InterestsQuery(
        type: 1, // Interested posts tab
        sort: sharedSortField.value,
        order: sharedSortOrder.value,
        search: searchValue,
      );

      final postsWithInterestsQuery = InterestsQuery(
        type: 2, // Posts with interests tab
        sort: sharedSortField.value,
        order: sharedSortOrder.value,
        search: searchValue,
      );

      // Load full data for current tab (default is tab 0)
      ref
          .read(interestedPostsProvider.notifier)
          .loadInterests(newQuery: interestedQuery, refresh: true);
      
      // Only load unread count for the other tab to optimize performance
      ref
          .read(postsWithInterestsProvider.notifier)
          .loadUnreadMessageCount(query: postsWithInterestsQuery);
    }

    // Handle tab changes - load full data for current tab if not loaded yet
    void onTabChanged() {
      if (tabController.indexIsChanging) return;
      
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
        final state = ref.read(interestedPostsProvider);
        // If interests list is empty or type doesn't match, load full data
        if (state.interests.isEmpty || state.query.type != 1) {
          ref
              .read(interestedPostsProvider.notifier)
              .loadInterests(newQuery: query, refresh: true);
        }
      } else {
        final state = ref.read(postsWithInterestsProvider);
        // If interests list is empty or type doesn't match, load full data
        if (state.interests.isEmpty || state.query.type != 2) {
          ref
              .read(postsWithInterestsProvider.notifier)
              .loadInterests(newQuery: query, refresh: true);
        }
      }
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
      // Mark messages as read for current tab when opening chat
      final currentTab = tabController.index;
      if (currentTab == 0) {
        // For interested posts tab, mark as read when opening chat
        ref.read(interestedPostsProvider.notifier).markAllMessagesAsRead();
      } else {
        // For posts with interests tab, mark as read when opening chat
        ref.read(postsWithInterestsProvider.notifier).markAllMessagesAsRead();
      }
      
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
    
    // Watch both provider states to get unread message counts
    final interestedPostsState = ref.watch(interestedPostsProvider);
    final postsWithInterestsState = ref.watch(postsWithInterestsProvider);

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
      appBarType: AppBarType.standard,
      body: Stack(
        children: [
          Column(
            children: [
              // Tab Bar with unread message badges
              InterestsTabBar(
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
                tabController: tabController,
                interestedPostsUnreadCount: interestedPostsState.unreadMessageCount,
                postsWithInterestsUnreadCount: postsWithInterestsState.unreadMessageCount,
              ),

              // Search and Filter Section
              SearchFilterSection(
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
                currentSortOrder: sharedSortOrder.value,
                searchController: sharedSearchController,
                onSearch: onSearch,
                onSortFilter: onSortFilter,
              ),

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
                      InterestedPostsTab(
                        isTablet: isTablet,
                        theme: theme,
                        colorScheme: colorScheme,
                        handlePostTap: handlePostTap,
                        handleChatTap: handleChatTap,
                        handleLikeTap: handleLikeTap,
                        searchController: sharedSearchController,
                        resetFilters: resetFilters,
                        scrollController: scrollController,
                      ),
                      PostsWithInterestsTab(
                        isTablet: isTablet,
                        theme: theme,
                        colorScheme: colorScheme,
                        handlePostTap: handlePostTap,
                        handleChatTap: handleChatTap,
                        searchController: sharedSearchController,
                        resetFilters: resetFilters,
                        scrollController: scrollController,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ScrollToTopButton(
            scrollController: scrollController,
            isTablet: isTablet,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}