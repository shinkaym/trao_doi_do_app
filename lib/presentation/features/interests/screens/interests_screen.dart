import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interest_query.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/interests_filter_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/interests_tab_bar.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/interested_posts_tab.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/interests_top_action_bar.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interests_screen/posts_with_interests_tab.dart';
import 'package:trao_doi_do_app/presentation/widgets/scroll_to_top_button.dart';
import 'package:trao_doi_do_app/presentation/providers/chat_notification_websocket_provider.dart';
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

    // Updated search state management to match PostsScreen
    final sharedSearchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final isSearchVisible = useState<bool>(false);
    final searchQuery = useState<String>('');

    final sharedSortField = useState('createdAt');
    final sharedSortOrder = useState('DESC');

    // Add debouncer for search
    final debouncer = useMemoized(() => Debouncer());

    final interestedPostsState = ref.watch(interestedPostsProvider);
    final postsWithInterestsState = ref.watch(postsWithInterestsProvider);

    final totalInterestedPostsUnreadCount =
        interestedPostsState.unreadMessageCount;
    final totalPostsWithInterestsUnreadCount =
        postsWithInterestsState.unreadMessageCount;

    void applySharedFiltersToCurrentTab() {
      final currentTab = tabController.index;
      final searchValue = searchQuery.value.isEmpty ? null : searchQuery.value;

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

    // Updated search handler with debouncing like PostsScreen
    void handleSearch(String query) {
      debouncer.debounce(
        duration: const Duration(milliseconds: 500),
        onDebounce: () {
          searchQuery.value = query;
          applySharedFiltersToCurrentTab();
        },
      );
    }

    // Reset search function
    void resetSearch() {
      searchQuery.value = '';
      sharedSearchController.clear();
      isSearchVisible.value = false;
      applySharedFiltersToCurrentTab();
    }

    // Reset filters
    void resetFilters() {
      sharedSortField.value = 'createdAt';
      sharedSortOrder.value = 'DESC';
      applySharedFiltersToCurrentTab();
    }

    // Reset all filters and search
    void resetAll() {
      searchQuery.value = '';
      sharedSearchController.clear();
      isSearchVisible.value = false;
      sharedSortField.value = 'createdAt';
      sharedSortOrder.value = 'DESC';
      applySharedFiltersToCurrentTab();
    }

    // Toggle search visibility
    void toggleSearch() {
      isSearchVisible.value = !isSearchVisible.value;
      if (isSearchVisible.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          searchFocusNode.requestFocus();
        });
      } else {
        searchFocusNode.unfocus();
        if (sharedSearchController.text.isEmpty) {
          resetSearch();
        }
      }
    }

    // Show filter bottom sheet
    void showFilterBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => InterestsFilterBottomSheet(
              selectedSort: sharedSortOrder.value,
              onApplySort: (order) {
                sharedSortOrder.value = order;
                applySharedFiltersToCurrentTab();
              },
              onResetFilters: resetFilters,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
            ),
      );
    }

    // WebSocket listener
    ref.listen<ChatNotificationWebSocketState>(
      chatNotificationWebSocketProvider,
      (previous, next) {
        if (previous?.lastResponse != next.lastResponse &&
            next.lastResponse?.event == 'send_message_response' &&
            next.lastResponse?.isSuccess == true &&
            next.lastResponse?.data != null) {
          final data = next.lastResponse!.data!;
          final messageType = data['type'] as String?;
          final interestID = data['interestID'] as int?;

          if (messageType != null && interestID != null) {
            if (messageType == 'followedBy') {
              ref
                  .read(postsWithInterestsProvider.notifier)
                  .incrementUnreadCount();
              ref
                  .read(postsWithInterestsProvider.notifier)
                  .incrementInterestUnreadCount(interestID);
            } else if (messageType == 'following') {
              ref.read(interestedPostsProvider.notifier).incrementUnreadCount();
              ref
                  .read(interestedPostsProvider.notifier)
                  .incrementInterestUnreadCount(interestID);
            }
          }
        }
      },
    );

    // Load initial data for both tabs
    void loadInitialData() {
      final searchValue = searchQuery.value.isEmpty ? null : searchQuery.value;

      final interestedQuery = InterestsQuery(
        type: 1,
        sort: sharedSortField.value,
        order: sharedSortOrder.value,
        search: searchValue,
      );

      final postsWithInterestsQuery = InterestsQuery(
        type: 2,
        sort: sharedSortField.value,
        order: sharedSortOrder.value,
        search: searchValue,
      );

      ref
          .read(interestedPostsProvider.notifier)
          .loadInterests(newQuery: interestedQuery, refresh: true);

      ref
          .read(postsWithInterestsProvider.notifier)
          .loadUnreadMessageCount(query: postsWithInterestsQuery);
    }

    // Handle tab changes
    void onTabChanged() {
      if (tabController.indexIsChanging) return;

      final currentTab = tabController.index;
      final searchValue = searchQuery.value.isEmpty ? null : searchQuery.value;

      final query = InterestsQuery(
        type: currentTab == 0 ? 1 : 2,
        sort: sharedSortField.value,
        order: sharedSortOrder.value,
        search: searchValue,
      );

      if (currentTab == 0) {
        final state = ref.read(interestedPostsProvider);
        if (state.interests.isEmpty || state.query.type != 1) {
          ref
              .read(interestedPostsProvider.notifier)
              .loadInterests(newQuery: query, refresh: true);
        }
      } else {
        final state = ref.read(postsWithInterestsProvider);
        if (state.interests.isEmpty || state.query.type != 2) {
          ref
              .read(postsWithInterestsProvider.notifier)
              .loadInterests(newQuery: query, refresh: true);
        }
      }
    }

    // Handle post tap
    void handlePostTap(String slug) {
      context.pushNamed(RouteNames.postDetail, pathParameters: {'slug': slug});
    }

    // Handle chat tap
    void handleChatTap(int interestId) {
      final currentTab = tabController.index;
      if (currentTab == 0) {
        ref
            .read(interestedPostsProvider.notifier)
            .resetInterestUnreadCount(interestId);
        final currentInterest = ref
            .read(interestedPostsProvider)
            .interests
            .expand((post) => post.interests)
            .firstWhere(
              (interest) => interest.id == interestId,
              orElse:
                  () => const Interest(
                    id: 0,
                    postID: 0,
                    userID: 0,
                    userName: '',
                    userAvatar: '',
                    status: 0,
                    createdAt: '',
                    newMessage: '',
                    messageFromID: 0,
                    newMessageIsRead: 0,
                    unreadMessageCount: 0,
                  ),
            );
        if (currentInterest.id != 0) {
          ref
              .read(interestedPostsProvider.notifier)
              .decreaseUnreadCount(currentInterest.unreadMessageCount);
        }
      } else {
        ref
            .read(postsWithInterestsProvider.notifier)
            .resetInterestUnreadCount(interestId);
        final currentInterest = ref
            .read(postsWithInterestsProvider)
            .interests
            .expand((post) => post.interests)
            .firstWhere(
              (interest) => interest.id == interestId,
              orElse:
                  () => const Interest(
                    id: 0,
                    postID: 0,
                    userID: 0,
                    userName: '',
                    userAvatar: '',
                    status: 0,
                    createdAt: '',
                    newMessage: '',
                    messageFromID: 0,
                    newMessageIsRead: 0,
                    unreadMessageCount: 0,
                  ),
            );
        if (currentInterest.id != 0) {
          ref
              .read(postsWithInterestsProvider.notifier)
              .decreaseUnreadCount(currentInterest.unreadMessageCount);
        }
      }

      context.pushNamed(
        RouteNames.interestChat,
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
      return () {
        debouncer.cancel();
      };
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

    return SmartScaffold(
      appBarType: AppBarType.standard,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Tab Bar with unread message badges
                InterestsTabBar(
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  tabController: tabController,
                  interestedPostsUnreadCount: totalInterestedPostsUnreadCount,
                  postsWithInterestsUnreadCount:
                      totalPostsWithInterestsUnreadCount,
                ),

                // Top Action Bar - New search interface similar to PostsScreen
                InterestsTopActionBar(
                  searchController: sharedSearchController,
                  searchFocusNode: searchFocusNode,
                  isSearchVisible: isSearchVisible.value,
                  onSearchChanged: handleSearch,
                  onSearchToggle: toggleSearch,
                  onSearchClear: resetSearch,
                  onFilterPressed: showFilterBottomSheet,
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                  hasActiveSearch: searchQuery.value.isNotEmpty,
                  hasActiveFilters: sharedSortOrder.value != 'DESC',
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
                          resetFilters: resetAll,
                          scrollController: scrollController,
                        ),
                        PostsWithInterestsTab(
                          isTablet: isTablet,
                          theme: theme,
                          colorScheme: colorScheme,
                          handlePostTap: handlePostTap,
                          handleChatTap: handleChatTap,
                          searchController: sharedSearchController,
                          resetFilters: resetAll,
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
      ),
    );
  }
}
