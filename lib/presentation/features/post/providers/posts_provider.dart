import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/usecases/params/post_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_posts_usecase.dart';

class PostsListState {
  final bool isLoading;
  final List<Post> posts;
  final int currentPage;
  final int totalPage;
  final PostsQuery query;
  final Failure? failure;
  final bool hasMoreData;
  final bool isLoadingPage;

  PostsListState({
    this.isLoading = false,
    this.posts = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const PostsQuery(),
    this.failure,
    this.hasMoreData = true,
    this.isLoadingPage = false,
  });

  PostsListState copyWith({
    bool? isLoading,
    List<Post>? posts,
    int? currentPage,
    int? totalPage,
    PostsQuery? query,
    Failure? failure,
    bool? hasMoreData,
    bool? isLoadingPage,
  }) {
    return PostsListState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage != null ? totalPage : this.totalPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
    );
  }
}

class PostsListNotifier extends StateNotifier<PostsListState> {
  final GetPostsUseCase _getPostsUseCase;

  int? _currentRequestId;
  int _nextRequestId = 1;

  PostsListNotifier(this._getPostsUseCase) : super(PostsListState());

  // Load posts với các tùy chọn khác nhau
  Future<void> loadPosts({
    PostsQuery? newQuery,
    bool refresh = false,
  }) async {
    if (state.isLoading || state.isLoadingPage) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.posts.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
      );
    } 

    final result = await _getPostsUseCase(query);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingPage: false,
            failure: failure,
          ),
      (postsResult) {
        List<Post> newPosts;

        if (isFirstLoad) {
          newPosts = postsResult.posts;
        } else {
          newPosts = state.posts;
        }

        final actualTotalPage = postsResult.totalPage;
        final actualCurrentPage = actualTotalPage > 0 ? state.query.page : 1;
        final actualHasMoreData =
            actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

        state = state.copyWith(
          isLoading: false,
          isLoadingPage: false,
          posts: newPosts,
          currentPage: actualCurrentPage,
          totalPage: actualTotalPage,
          hasMoreData: actualHasMoreData,
        );
      },
    );
  }

  // Chuyển đến trang cụ thể
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPage) return;

    final requestId = _nextRequestId++;
    _currentRequestId = requestId;

    state = state.copyWith(currentPage: page, isLoadingPage: true);

    final newQuery = state.query.copyWith(page: page);

    try {
      final result = await _getPostsUseCase(newQuery);

      // Kiểm tra xem request này còn là request mới nhất không
      if (_currentRequestId != requestId) {
        // Nếu có request mới hơn, bỏ qua kết quả này
        return;
      }

      result.fold(
        (failure) {
          // Chỉ cập nhật failure, không rollback currentPage
          state = state.copyWith(failure: failure, isLoadingPage: false);
        },
        (postsResult) {
          final actualTotalPage = postsResult.totalPage;
          final actualCurrentPage = actualTotalPage > 0 ? page : 1;
          final actualHasMoreData =
              actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

          state = state.copyWith(
            posts: postsResult.posts,
            currentPage: actualCurrentPage,
            totalPage: actualTotalPage,
            hasMoreData: actualHasMoreData,
            failure: null,
            isLoadingPage: false,
          );
        },
      );
    } catch (e) {
      // Kiểm tra xem request này còn là request mới nhất không
      if (_currentRequestId != requestId) {
        return;
      }

      // Chỉ cập nhật trạng thái lỗi, không rollback currentPage
      state = state.copyWith(isLoadingPage: false);
    }
  }

  // Chuyển đến trang trước
  Future<void> goToPreviousPage() async {
    if (state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    }
  }

  // Chuyển đến trang tiếp theo
  Future<void> goToNextPage() async {
    if (state.currentPage < state.totalPage) {
      await goToPage(state.currentPage + 1);
    }
  }

  // Chuyển đến trang đầu
  Future<void> goToFirstPage() async {
    await goToPage(1);
  }

  // Chuyển đến trang cuối
  Future<void> goToLastPage() async {
    await goToPage(state.totalPage);
  }

  // Filter methods (giữ nguyên)
  void filterByType(int? type) {
    final newQuery = state.query.copyWith(type: type);
    loadPosts(newQuery: newQuery, refresh: true);
  }

  void search(String? search) {
    final newQuery = state.query.copyWith(search: search);
    loadPosts(newQuery: newQuery, refresh: true);
  }

  void sortPosts(String? sort, String? order) {
    final newQuery = state.query.copyWith(sort: sort, order: order);
    loadPosts(newQuery: newQuery, refresh: true);
  }

  void applyFilter({String? search, int? type, String? sort, String? order}) {
    final newQuery = state.query.copyWith(
      search: search,
      type: type,
      sort: sort,
      order: order,
      page: 1,
    );
    loadPosts(newQuery: newQuery, refresh: true);
  }

  void refresh() {
    loadPosts(refresh: true);
  }
}
