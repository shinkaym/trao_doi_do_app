import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/usecases/params/post_query.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/create_post_fab.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/posts_list_content.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/search_filter_section.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class PostsScreen extends HookConsumerWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final selectedType = useState<PostType>(PostType.all);
    final selectedSort = useState<SortOrder>(SortOrder.newest);
    final searchQuery = useState<String>('');

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
      searchQuery.value = query;
      loadPosts(refresh: true);
    }

    void handleTypeFilter(PostType type) {
      selectedType.value = type;
      loadPosts(refresh: true);
    }

    void handleSortFilter(SortOrder sort) {
      selectedSort.value = sort;
      loadPosts(refresh: true);
    }

    void handleRefresh() {
      loadPosts(refresh: true);
    }

    void handlePostTap(Post post) {
      // Navigate to post detail
      context.pushNamed(
        'post-detail',
        pathParameters: {'slug': post.slug.toString()},
      );
    }

    void handleCreatePost() {
      // Navigate to create post
      context.pushNamed('create-post');
    }

    void resetFilters() {
      searchQuery.value = '';
      selectedType.value = PostType.all;
      selectedSort.value = SortOrder.newest;
      searchController.clear();
      loadPosts(refresh: true);
    }

    // Load posts lần đầu
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadPosts();
      });
      return null;
    }, []);

    return SmartScaffold(
      title: 'Bài đăng',
      appBarType: AppBarType.standard,
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Section
            SearchFilterSection(
              searchController: searchController,
              selectedType: selectedType.value,
              selectedSort: selectedSort.value,
              searchQuery: searchQuery.value,
              onSearch: handleSearch,
              onTypeFilter: handleTypeFilter,
              onSortFilter: handleSortFilter,
              postsCount: postsState.posts.length,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
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
                onResetFilters: resetFilters,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CreatePostFAB(
        onPressed: handleCreatePost,
        isTablet: isTablet,
        colorScheme: colorScheme,
      ),
    );
  }
}
