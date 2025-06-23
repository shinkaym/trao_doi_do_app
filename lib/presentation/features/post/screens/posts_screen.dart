import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/usecases/params/post_query.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/posts_filter_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/posts_list_content.dart';
import 'package:trao_doi_do_app/presentation/widgets/scroll_to_top_button.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/posts_top_action_bar.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class PostsScreen extends HookConsumerWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final selectedType = useState<PostType>(PostType.all);
    final selectedSort = useState<SortOrder>(SortOrder.newest);
    final searchQuery = useState<String>('');
    final scrollController = useScrollController();
    final searchFocusNode = useFocusNode();
    final isSearchVisible = useState<bool>(false);

    final debouncer = useMemoized(() => Debouncer());

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final postsState = ref.watch(postsListProvider);

    void loadPosts({bool refresh = false}) {
      final query = PostsQuery(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        type: selectedType.value.value,
        sort: selectedSort.value.sort,
        order: selectedSort.value.order,
        page: refresh ? 1 : 1,
      );

      ref
          .read(postsListProvider.notifier)
          .loadPosts(newQuery: query, refresh: refresh);
    }

    void handleSearch(String query) {
      debouncer.debounce(
        duration: const Duration(milliseconds: 500),
        onDebounce: () {
          searchQuery.value = query;
          loadPosts(refresh: true);
        },
      );
    }

    void handleApplyFilters(PostType type, SortOrder sort) {
      selectedType.value = type;
      selectedSort.value = sort;
      loadPosts(refresh: true);
    }

    void handleRefresh() {
      loadPosts(refresh: true);
    }

    void handlePostTap(Post post) {
      context.pushNamed(
        'post-detail',
        pathParameters: {'slug': post.slug.toString()},
      );
    }

    void handleCreatePost() {
      context.pushNamed('create-post');
    }

    void resetFilters() {
      selectedType.value = PostType.all;
      selectedSort.value = SortOrder.newest;
      loadPosts(refresh: true);
    }

    void resetSearch() {
      searchQuery.value = '';
      searchController.clear();
      isSearchVisible.value = false;
      loadPosts(refresh: true);
    }

    void resetAll() {
      searchQuery.value = '';
      selectedType.value = PostType.all;
      selectedSort.value = SortOrder.newest;
      searchController.clear();
      isSearchVisible.value = false;
      loadPosts(refresh: true);
    }

    void showFilterBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => PostsFilterBottomSheet(
              selectedType: selectedType.value,
              selectedSort: selectedSort.value,
              onApplyFilters: handleApplyFilters,
              onResetFilters: resetFilters,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
            ),
      );
    }

    void toggleSearch() {
      isSearchVisible.value = !isSearchVisible.value;
      if (isSearchVisible.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          searchFocusNode.requestFocus();
        });
      } else {
        searchFocusNode.unfocus();
        if (searchController.text.isEmpty) {
          resetSearch();
        }
      }
    }

    // Load posts lần đầu
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadPosts();
      });
      return () {
        debouncer.cancel();
      };
    }, []);

    return SmartScaffold(
      appBarType: AppBarType.standard,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Action Bar
                PostsTopActionBar(
                  searchController: searchController,
                  searchFocusNode: searchFocusNode,
                  isSearchVisible: isSearchVisible.value,
                  onSearchChanged: handleSearch,
                  onSearchToggle: toggleSearch,
                  onSearchClear: resetSearch,
                  onFilterPressed: showFilterBottomSheet,
                  onCreatePressed: handleCreatePost,
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                  hasActiveSearch: searchQuery.value.isNotEmpty,
                  hasActiveFilters:
                      selectedType.value != PostType.all ||
                      selectedSort.value != SortOrder.newest,
                ),

                // Content
                Expanded(
                  child: PostsListContent(
                    postsState: postsState,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    searchQuery: searchQuery.value,
                    selectedType: selectedType.value,
                    selectedSort: selectedSort.value,
                    onPostTap: handlePostTap,
                    onRefresh: handleRefresh,
                    onResetFilters: resetAll,
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),

            // Scroll to top button
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
