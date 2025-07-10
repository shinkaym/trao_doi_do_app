import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/usecases/params/post_query.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/my-posts/my_posts_filter_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/my-posts/my_posts_list_content.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/my-posts/my_posts_top_action_bar.dart';
import 'package:trao_doi_do_app/presentation/widgets/scroll_to_top_button.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class MyPostsScreen extends HookConsumerWidget {
  const MyPostsScreen({super.key});

  void _onToggleStatus(BuildContext context, WidgetRef ref, Post post) async {
    final postNotifier = ref.read(postProvider.notifier);
    final isLocked = post.status == PostStatus.locked.value;
    final actionText = isLocked ? 'mở khóa' : 'khóa';

    final confirmed = await context.showConfirmDialog(
      title: 'Xác nhận',
      content: 'Bạn có chắc chắn muốn $actionText quan tâm của bài đăng này?',
      confirmText: 'Xác nhận',
      cancelText: 'Hủy',
    );

    if (confirmed == true) {
      try {
        context.showLoadingDialog(message: 'Đang xử lý...');

        await postNotifier.togglePostStatus(post.id!, post.status ?? 3);

        context.dismissDialog();
        ref.read(myPostsListProvider.notifier).refresh();
      } catch (e) {
        context.dismissDialog();
        // Không cần show error snackbar ở đây nữa, useEffect sẽ xử lý
      }
    }
  }

  void _onRepost(BuildContext context, WidgetRef ref, Post post) async {
    final postNotifier = ref.read(postProvider.notifier);

    final now = DateTime.now();
    final difference = now.difference(post.createdAt!);
    final canRepost = difference.inDays >= 7;

    if (!canRepost) {
      final now = DateTime.now();
      final createdAt = post.createdAt!;
      final difference = now.difference(createdAt);
      final remainingDays = 7 - difference.inDays;

      context.showInfoDialog(
        title: 'Thông báo',
        content:
            'Chỉ có thể ghim sau 1 tuần từ lần đăng cuối! Còn lại $remainingDays ngày.',
        icon: Icons.info_outline,
      );
      return;
    }

    final confirmed = await context.showConfirmDialog(
      title: 'Xác nhận ghim',
      content: 'Bạn có chắc chắn muốn ghim bài đăng này?',
      confirmText: 'Ghim',
      cancelText: 'Hủy',
    );

    if (confirmed == true) {
      try {
        context.showLoadingDialog(message: 'Đang ghim...');

        await postNotifier.repostPost(post.id!, post.createdAt!);

        context.dismissDialog();
        ref.read(myPostsListProvider.notifier).refresh();
      } catch (e) {
        context.dismissDialog();
        // Không cần show error snackbar ở đây nữa, useEffect sẽ xử lý
      }
    }
  }

  // Thêm function xóa bài đăng
  void _onDeletePost(BuildContext context, WidgetRef ref, Post post) async {
    final postNotifier = ref.read(postProvider.notifier);

    final confirmed = await context.showConfirmDialog(
      title: 'Xác nhận xóa',
      content:
          'Bạn có chắc chắn muốn xóa bài đăng này? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
    );

    if (confirmed == true) {
      try {
        context.showLoadingDialog(message: 'Đang xóa bài đăng...');

        await postNotifier.deletePost(post.id!);

        context.dismissDialog();
        ref.read(myPostsListProvider.notifier).refresh();
      } catch (e) {
        context.dismissDialog();
        // Không cần show error snackbar ở đây nữa, useEffect sẽ xử lý
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(myPostsListProvider);
    final postState = ref.watch(postProvider);
    
    final scrollController = useScrollController();
    final searchFocusNode = useFocusNode();
    final isSearchVisible = useState<bool>(false);

    final debouncer = useMemoized(() => Debouncer());

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    final searchQuery = useState<String>('');

    final searchController = useTextEditingController(
      text: postsState.query.search ?? '',
    );

    final selectedType = useState<PostType>(
      postsState.query.type != null
          ? PostType.values.firstWhere(
            (type) => type.value == postsState.query.type,
            orElse: () => PostType.all,
          )
          : PostType.all,
    );

    final selectedSort = useState<SortOrder>(
      postsState.query.sort != null && postsState.query.order != null
          ? SortOrder.timeSortOptions.firstWhere(
            (sort) =>
                sort.sort == postsState.query.sort &&
                sort.order == postsState.query.order,
            orElse: () => SortOrder.newest,
          )
          : SortOrder.newest,
    );

    final selectedStatus = useState<PostStatus>(
      postsState.query.status != null
          ? PostStatus.values.firstWhere(
            (status) => status.value == postsState.query.status,
            orElse: () => PostStatus.all,
          )
          : PostStatus.all,
    );

    useEffect(() {
      if (postState.successMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showSuccessSnackBar(postState.successMessage!);
          ref.read(postProvider.notifier).clearMessages();
        });
      }

      if (postState.failure != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showErrorSnackBar(postState.failure!.message);
          ref.read(postProvider.notifier).clearMessages();
        });
      }

      return null;
    }, [postState.successMessage, postState.failure]);

    void loadPosts({bool refresh = false}) {
      final query = PostsQuery(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        type: selectedType.value.value,
        status: selectedStatus.value.value,
        sort: selectedSort.value.sort,
        order: selectedSort.value.order,
        page: refresh ? 1 : postsState.currentPage,
      );

      ref
          .read(myPostsListProvider.notifier)
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

    void handleApplyFilters(PostType type, SortOrder sort, PostStatus status) {
      selectedType.value = type;
      selectedSort.value = sort;
      selectedStatus.value = status;
      loadPosts(refresh: true);
    }

    void handleRefresh() {
      loadPosts(refresh: true);
    }

    void handlePostTap(Post post) {
      context.pushNamed(
        RouteNames.postDetail,
        pathParameters: {'slug': post.slug.toString()},
      );
    }

    void handleCreatePost() {
      context.pushNamed(RouteNames.createPost);
    }

    void resetFilters() {
      selectedType.value = PostType.all;
      selectedSort.value = SortOrder.newest;
      selectedStatus.value = PostStatus.all;
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
      selectedStatus.value = PostStatus.all;
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
            (context) => MyPostsFilterBottomSheet(
              selectedType: selectedType.value,
              selectedSort: selectedSort.value,
              selectedStatus: selectedStatus.value,
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
        if (postsState.posts.isEmpty) {
          loadPosts();
        }
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
                MyPostsTopActionBar(
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
                      selectedSort.value != SortOrder.newest ||
                      selectedStatus.value != PostStatus.all,
                ),

                // Content
                Expanded(
                  child: MyPostsListContent(
                    postsState: postsState,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    searchQuery: searchQuery.value,
                    selectedType: selectedType.value,
                    selectedSort: selectedSort.value,
                    selectedStatus: selectedStatus.value,
                    onPostTap: handlePostTap,
                    onRefresh: handleRefresh,
                    onResetFilters: resetAll,
                    scrollController: scrollController,
                    onToggleStatus:
                        (post) => _onToggleStatus(context, ref, post),
                    onRepost: (post) => _onRepost(context, ref, post),
                    onDelete: (post) => _onDeletePost(context, ref, post),
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
