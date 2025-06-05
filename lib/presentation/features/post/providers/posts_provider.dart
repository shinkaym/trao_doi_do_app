import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/entities/params/posts_query.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/get_posts_usecase.dart';

class PostsListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Post> posts;
  final int currentPage;
  final int totalPage;
  final PostsQuery query;
  final Failure? failure;
  final bool hasMoreData;

  PostsListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.posts = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const PostsQuery(),
    this.failure,
    this.hasMoreData = true,
  });

  PostsListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Post>? posts,
    int? currentPage,
    int? totalPage,
    PostsQuery? query,
    Failure? failure,
    bool? hasMoreData,
  }) {
    return PostsListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class PostsListNotifier extends StateNotifier<PostsListState> {
  final GetPostsUseCase _getPostsUseCase;

  PostsListNotifier(this._getPostsUseCase) : super(PostsListState());

  // Load posts with refresh option
  Future<void> loadPosts({PostsQuery? newQuery, bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.posts.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
      );
    } else {
      // Load more
      if (!state.hasMoreData || state.currentPage >= state.totalPage) return;

      state = state.copyWith(
        isLoadingMore: true,
        failure: null,
        query: query.copyWith(page: state.currentPage + 1),
      );
    }

    final result = await _getPostsUseCase(state.query);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            failure: failure,
          ),
      (postsResult) {
        final newPosts =
            isFirstLoad
                ? postsResult.posts
                : [...state.posts, ...postsResult.posts];

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          posts: newPosts,
          currentPage: state.query.page,
          totalPage: postsResult.totalPage,
          hasMoreData: state.query.page < postsResult.totalPage,
        );
      },
    );
  }

  // Filter methods
  void filterByType(int? type) {
    final newQuery = state.query.copyWith(type: type);
    loadPosts(newQuery: newQuery, refresh: true);
  }

  void filterByStatus(int? status) {
    final newQuery = state.query.copyWith(status: status);
    loadPosts(newQuery: newQuery, refresh: true);
  }

  void search(String? searchBy, String? searchValue) {
    final newQuery = state.query.copyWith(
      searchBy: searchBy,
      searchValue: searchValue,
    );
    loadPosts(newQuery: newQuery, refresh: true);
  }

  void sortPosts(String? sort, String? order) {
    final newQuery = state.query.copyWith(sort: sort, order: order);
    loadPosts(newQuery: newQuery, refresh: true);
  }

  void loadMore() {
    loadPosts();
  }

  void refresh() {
    loadPosts(refresh: true);
  }
}

final postsListProvider =
    StateNotifierProvider<PostsListNotifier, PostsListState>((ref) {
      final getPostsUseCase = ref.watch(getPostsUseCaseProvider);
      return PostsListNotifier(getPostsUseCase);
    });
