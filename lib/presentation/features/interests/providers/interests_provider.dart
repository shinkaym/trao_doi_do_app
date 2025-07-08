import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interest_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_interests_usecase.dart';

class InterestsListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<InterestPost> interests;
  final int currentPage;
  final int totalPage;
  final InterestsQuery query;
  final Failure? failure;
  final bool hasMoreData;
  final bool isLoadingPage;
  final int unreadMessageCount;
  final bool isLoadingUnreadCount;
  InterestsListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.interests = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const InterestsQuery(order: 'DESC'),
    this.failure,
    this.hasMoreData = true,
    this.isLoadingPage = false,
    this.unreadMessageCount = 0, // Default to 0
    this.isLoadingUnreadCount = false,
  });

  InterestsListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<InterestPost>? interests,
    int? currentPage,
    int? totalPage,
    InterestsQuery? query,
    Failure? failure,
    bool? hasMoreData,
    bool? isLoadingPage,
    int? unreadMessageCount,
    bool? isLoadingUnreadCount,
  }) {
    return InterestsListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      interests: interests ?? this.interests,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
      isLoadingUnreadCount: isLoadingUnreadCount ?? this.isLoadingUnreadCount,
    );
  }
}

class InterestsListNotifier extends StateNotifier<InterestsListState> {
  final GetInterestsUseCase _getInterestsUseCase;

  InterestsListNotifier(this._getInterestsUseCase)
    : super(InterestsListState());

  Future<void> loadInterests({
    InterestsQuery? newQuery,
    bool refresh = false,
    bool isLoadMore = false,
    bool isGoToPage = false,
  }) async {
    if (state.isLoading || state.isLoadingMore || state.isLoadingPage) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.interests.isEmpty;
    final isTypeChanged = newQuery != null && newQuery.type != state.query.type;

    if (isTypeChanged || isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
        interests: [],
      );
    } else if (isLoadMore) {
      if (!state.hasMoreData || state.currentPage >= state.totalPage) return;

      state = state.copyWith(
        isLoadingMore: true,
        failure: null,
        query: query.copyWith(page: state.currentPage + 1),
      );
    } else if (isGoToPage) {
      state = state.copyWith(isLoadingPage: true, failure: null, query: query);
    }

    try {
      final result = await _getInterestsUseCase(state.query);

      result.fold(
        (failure) =>
            state = state.copyWith(
              isLoading: false,
              isLoadingMore: false,
              isLoadingPage: false,
              failure: failure,
            ),
        (interestsResult) {
          List<InterestPost> newInterests;

          if (isTypeChanged || isFirstLoad) {
            newInterests = interestsResult.interests;
          } else if (isLoadMore) {
            newInterests = [...state.interests, ...interestsResult.interests];
          } else if (isGoToPage) {
            newInterests = interestsResult.interests;
          } else {
            newInterests = state.interests;
          }

          final actualTotalPage = interestsResult.totalPage;
          final actualCurrentPage = actualTotalPage > 0 ? state.query.page : 1;
          final actualHasMoreData =
              actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            isLoadingPage: false,
            interests: newInterests,
            currentPage: actualCurrentPage,
            totalPage: actualTotalPage,
            hasMoreData: actualHasMoreData,
            failure: null, // Clear failure khi success
            unreadMessageCount:
                interestsResult.unreadMessageCount, // Update unread count
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        isLoadingPage: false,
        failure: ServerFailure('Đã xảy ra lỗi không mong muốn'),
      );
    }
  }

  // New method to load only unread message count without loading posts
  Future<void> loadUnreadMessageCount({InterestsQuery? query}) async {
    if (state.isLoadingUnreadCount) return;

    state = state.copyWith(isLoadingUnreadCount: true);

    try {
      final queryToUse = query ?? state.query;
      // Create a query with minimal data - just get first page with 1 item to get unread count
      final countQuery = queryToUse.copyWith(page: 1, limit: 1);

      final result = await _getInterestsUseCase(countQuery);

      result.fold(
        (failure) => state = state.copyWith(isLoadingUnreadCount: false),
        (interestsResult) {
          state = state.copyWith(
            isLoadingUnreadCount: false,
            unreadMessageCount: interestsResult.unreadMessageCount,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoadingUnreadCount: false);
    }
  }

  // Method to decrease unread count when messages are read
  void decreaseUnreadCount(int countToDecrease) {
    final newTotalCount = state.unreadMessageCount - countToDecrease;
    final finalCount = newTotalCount < 0 ? 0 : newTotalCount;
    state = state.copyWith(unreadMessageCount: finalCount);
  }

  // Pagination methods
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPage || page == state.currentPage) return;
    final newQuery = state.query.copyWith(page: page);
    await loadInterests(newQuery: newQuery, isGoToPage: true);
  }

  Future<void> goToPreviousPage() async {
    if (state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    }
  }

  Future<void> goToNextPage() async {
    if (state.currentPage < state.totalPage) {
      await goToPage(state.currentPage + 1);
    }
  }

  void search(String? search) {
    final newQuery = state.query.copyWith(search: search, page: 1);
    loadInterests(newQuery: newQuery, refresh: true);
  }

  void loadMore() {
    loadInterests(isLoadMore: true);
  }

  void refresh() {
    loadInterests(refresh: true);
  }

  void incrementUnreadCount() {
    state = state.copyWith(unreadMessageCount: state.unreadMessageCount + 1);
  }

  // Method để tăng unread count cho một interest cụ thể
  void incrementInterestUnreadCount(int interestId) {
    final updatedPosts =
        state.interests.map((post) {
          // Find if this post contains the interest
          final updatedInterests =
              post.interests.map((interest) {
                if (interest.id == interestId) {
                  // Create updated interest with incremented count
                  return Interest(
                    id: interest.id,
                    postID: interest.postID,
                    userID: interest.userID,
                    userName: interest.userName,
                    userAvatar: interest.userAvatar,
                    status: interest.status,
                    createdAt: interest.createdAt,
                    newMessage: interest.newMessage,
                    messageFromID: interest.messageFromID,
                    newMessageIsRead: interest.newMessageIsRead,
                    unreadMessageCount: interest.unreadMessageCount + 1,
                  );
                }
                return interest;
              }).toList();

          // Check if any interest in this post was updated
          final hasUpdatedInterest = updatedInterests.any(
            (interest) => interest.id == interestId,
          );

          if (hasUpdatedInterest) {
            // Calculate new total unread count for this post
            final newPostUnreadCount = updatedInterests.fold<int>(
              0,
              (sum, interest) => sum + interest.unreadMessageCount,
            );

            // Return updated post with new interests and total count
            return InterestPost(
              id: post.id,
              slug: post.slug,
              title: post.title,
              type: post.type,
              description: post.description,
              createdAt: post.createdAt,
              updatedAt: post.updatedAt,
              authorID: post.authorID,
              authorName: post.authorName,
              authorAvatar: post.authorAvatar,
              interests: updatedInterests,
              items: post.items,
              unreadMessageCount: newPostUnreadCount,
            );
          }

          return post;
        }).toList();

    state = state.copyWith(interests: updatedPosts);
  }

  // Method để reset unread count cho một interest cụ thể khi user vào chat
  void resetInterestUnreadCount(int interestId) {
    final updatedPosts =
        state.interests.map((post) {
          // Find if this post contains the interest
          final updatedInterests =
              post.interests.map((interest) {
                if (interest.id == interestId) {
                  // Create updated interest with reset count
                  return Interest(
                    id: interest.id,
                    postID: interest.postID,
                    userID: interest.userID,
                    userName: interest.userName,
                    userAvatar: interest.userAvatar,
                    status: interest.status,
                    createdAt: interest.createdAt,
                    newMessage: interest.newMessage,
                    messageFromID: interest.messageFromID,
                    newMessageIsRead: 1, // Mark as read
                    unreadMessageCount: 0, // Reset to 0
                  );
                }
                return interest;
              }).toList();

          // Check if any interest in this post was updated
          final hasUpdatedInterest = updatedInterests.any(
            (interest) => interest.id == interestId,
          );

          if (hasUpdatedInterest) {
            // Calculate new total unread count for this post
            final newPostUnreadCount = updatedInterests.fold<int>(
              0,
              (sum, interest) => sum + interest.unreadMessageCount,
            );

            // Return updated post with new interests and total count
            return InterestPost(
              id: post.id,
              slug: post.slug,
              title: post.title,
              type: post.type,
              description: post.description,
              createdAt: post.createdAt,
              updatedAt: post.updatedAt,
              authorID: post.authorID,
              authorName: post.authorName,
              authorAvatar: post.authorAvatar,
              interests: updatedInterests,
              items: post.items,
              unreadMessageCount: newPostUnreadCount,
            );
          }

          return post;
        }).toList();

    state = state.copyWith(interests: updatedPosts);
  }
}
