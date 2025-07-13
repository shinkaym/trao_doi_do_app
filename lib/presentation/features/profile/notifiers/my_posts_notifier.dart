import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/usecases/get_my_posts_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/params/post_query.dart';

class MyPostsListState {
  final bool isLoading;
  final List<Post> posts;
  final int currentPage;
  final int totalPage;
  final PostsQuery query;
  final Failure? failure;
  final bool hasMoreData;
  final bool isLoadingPage;
  final Map<int, bool> postUpdatingStatus;

  MyPostsListState({
    this.isLoading = false,
    this.posts = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const PostsQuery(),
    this.failure,
    this.hasMoreData = true,
    this.isLoadingPage = false,
    this.postUpdatingStatus = const {},
  });

  MyPostsListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Post>? posts,
    int? currentPage,
    int? totalPage,
    PostsQuery? query,
    Failure? failure,
    bool? hasMoreData,
    bool? isLoadingPage,
    Map<int, bool>? postUpdatingStatus,
  }) {
    return MyPostsListState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage != null ? totalPage : this.totalPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
      postUpdatingStatus: postUpdatingStatus ?? this.postUpdatingStatus,
    );
  }
}

class MyPostsListNotifier extends StateNotifier<MyPostsListState> {
  final GetMyPostsUseCase _getMyPostsUseCase;
  int? _currentRequestId;
  int _nextRequestId = 1;
  MyPostsListNotifier(this._getMyPostsUseCase) : super(MyPostsListState());

  Future<void> loadPosts({PostsQuery? newQuery, bool refresh = false}) async {
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

    final result = await _getMyPostsUseCase(query);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
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

  void updatePostStatus(int postId, int newStatus) {
    final updatedPosts =
        state.posts.map((post) {
          if (post.id == postId) {
            return Post(
              id: post.id,
              authorID: post.authorID,
              authorName: post.authorName,
              authorAvatar: post.authorAvatar,
              title: post.title,
              description: post.description,
              info: post.info,
              type: post.type,
              slug: post.slug,
              status: newStatus,
              images: post.images,
              newItems: post.newItems,
              oldItems: post.oldItems,
              tags: post.tags,
              interestCount: post.interestCount,
              itemCount: post.itemCount,
              currentItemCount: post.currentItemCount,
              createdAt: post.createdAt,
            );
          }
          return post;
        }).toList();

    state = state.copyWith(posts: updatedPosts);
  }

  void setPostUpdatingStatus(int postId, bool isUpdating) {
    final updatedStatus = Map<int, bool>.from(state.postUpdatingStatus);
    if (isUpdating) {
      updatedStatus[postId] = true;
    } else {
      updatedStatus.remove(postId);
    }

    state = state.copyWith(postUpdatingStatus: updatedStatus);
  }

  void updatePostAfterRepost(int postId, DateTime newCreatedAt) {
    final updatedPosts =
        state.posts.map((post) {
          if (post.id == postId) {
            return Post(
              id: post.id,
              authorID: post.authorID,
              authorName: post.authorName,
              authorAvatar: post.authorAvatar,
              title: post.title,
              description: post.description,
              info: post.info,
              type: post.type,
              slug: post.slug,
              status: post.status,
              images: post.images,
              newItems: post.newItems,
              oldItems: post.oldItems,
              tags: post.tags,
              interestCount: post.interestCount,
              itemCount: post.itemCount,
              currentItemCount: post.currentItemCount,
              createdAt: newCreatedAt,
            );
          }
          return post;
        }).toList();

    state = state.copyWith(posts: updatedPosts);
  }

  void removePost(int postId) {
    final updatedPosts =
        state.posts.where((post) => post.id != postId).toList();
    state = state.copyWith(posts: updatedPosts);
  }

  // Chuyển đến trang cụ thể
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPage || page == state.currentPage) return;

    // Tạo requestId mới cho lần gọi này
    final requestId = _nextRequestId++;
    _currentRequestId = requestId;

    // Hiển thị loading state khi chuyển trang
    state = state.copyWith(
      currentPage: page,
      isLoadingPage: true, // Bật loading để hiển thị skeleton
    );

    final newQuery = state.query.copyWith(page: page);

    try {
      final result = await _getMyPostsUseCase(newQuery);

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

  void refresh() {
    loadPosts(refresh: true);
  }
}
