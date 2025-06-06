import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/params/posts_query.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/posts_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/create_post_fab.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/posts_list_content.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/search_filter_section.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  final TextEditingController _searchController = TextEditingController();
  PostType _selectedType = PostType.all;
  SortOrder _selectedSort = SortOrder.newest;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load posts lần đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPosts({bool refresh = false}) {
    final query = PostsQuery(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      type: _selectedType.value,
      sort: _selectedSort.sort,
      order: _selectedSort.order,
      page: refresh ? 1 : 1,
    );

    ref
        .read(postsListProvider.notifier)
        .loadPosts(newQuery: query, refresh: refresh);
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadPosts(refresh: true);
  }

  void _handleTypeFilter(PostType type) {
    setState(() {
      _selectedType = type;
    });
    _loadPosts(refresh: true);
  }

  void _handleSortFilter(SortOrder sort) {
    setState(() {
      _selectedSort = sort;
    });
    _loadPosts(refresh: true);
  }

  void _handleRefresh() {
    _loadPosts(refresh: true);
  }

  void _handlePostTap(Post post) {
    // Navigate to post detail
    context.pushNamed(
      'post-detail',
      pathParameters: {'slug': post.slug.toString()},
    );
  }

  void _handleCreatePost() {
    // Navigate to create post
    context.pushNamed('create-post');
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final postsState = ref.watch(postsListProvider);

    return SmartScaffold(
      title: 'Bài đăng',
      appBarType: AppBarType.standard,
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Section
            SearchFilterSection(
              searchController: _searchController,
              selectedType: _selectedType,
              selectedSort: _selectedSort,
              searchQuery: _searchQuery,
              onSearch: _handleSearch,
              onTypeFilter: _handleTypeFilter,
              onSortFilter: _handleSortFilter,
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
                searchQuery: _searchQuery,
                selectedType: _selectedType,
                selectedSort: _selectedSort,
                onPostTap: _handlePostTap,
                onRefresh: _handleRefresh,
                onResetFilters: _resetFilters,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CreatePostFAB(
        onPressed: _handleCreatePost,
        isTablet: isTablet,
        colorScheme: colorScheme,
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedType = PostType.all;
      _selectedSort = SortOrder.newest;
    });
    _searchController.clear();
    _loadPosts(refresh: true);
  }
}
