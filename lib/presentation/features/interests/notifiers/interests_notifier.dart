import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interest_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_interests_usecase.dart';

class InterestsListState {
  final int selectedTab;
  final bool isLoading;
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
    this.selectedTab = 0,
    this.isLoading = false,
    this.interests = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const InterestsQuery(order: 'DESC'),
    this.failure,
    this.hasMoreData = true,
    this.isLoadingPage = false,
    this.unreadMessageCount = 0,
    this.isLoadingUnreadCount = false,
  });

  InterestsListState copyWith({
    int? selectedTab,
    bool? isLoading,
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
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
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

  int? _currentRequestId;
  int _nextRequestId = 1;

  InterestsListNotifier(this._getInterestsUseCase)
    : super(InterestsListState());

  Future<void> loadInterests({
    InterestsQuery? newQuery,
    bool refresh = false,
  }) async {
    if (state.isLoading || state.isLoadingPage) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.interests.isEmpty;
    final isTypeChanged = newQuery != null && newQuery.type != state.query.type;
    final isSearchChanged =
        newQuery != null && newQuery.search != state.query.search;

    if (isTypeChanged || isFirstLoad || isSearchChanged) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
      );
    }

    try {
      final result = await _getInterestsUseCase(state.query);

      result.fold(
        (failure) =>
            state = state.copyWith(
              isLoading: false,
              isLoadingPage: false,
              failure: failure,
            ),
        (interestsResult) {
          List<InterestPost> newInterests;

          if (isTypeChanged || isFirstLoad) {
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
            isLoadingPage: false,
            interests: newInterests,
            currentPage: actualCurrentPage,
            totalPage: actualTotalPage,
            hasMoreData: actualHasMoreData,
            failure: null,
            unreadMessageCount: interestsResult.unreadMessageCount,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingPage: false,
        failure: ServerFailure('Đã xảy ra lỗi không mong muốn'),
      );
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

    // Tạo requestId mới cho lần gọi này
    final requestId = _nextRequestId++;
    _currentRequestId = requestId;

    // Cập nhật UI ngay lập tức - hiển thị skeleton
    state = state.copyWith(currentPage: page, isLoadingPage: true);

    final newQuery = state.query.copyWith(page: page);

    try {
      final result = await _getInterestsUseCase(newQuery);

      // Kiểm tra xem request này còn là request mới nhất không
      if (_currentRequestId != requestId) return;

      result.fold(
        (failure) {
          state = state.copyWith(failure: failure, isLoadingPage: false);
        },
        (interestsResult) {
          final actualTotalPage = interestsResult.totalPage;
          final actualCurrentPage = actualTotalPage > 0 ? page : 1;
          final actualHasMoreData =
              actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

          state = state.copyWith(
            interests: interestsResult.interests,
            currentPage: actualCurrentPage,
            totalPage: actualTotalPage,
            hasMoreData: actualHasMoreData,
            failure: null,
            isLoadingPage: false,
            unreadMessageCount: interestsResult.unreadMessageCount,
          );
        },
      );
    } catch (e) {
      if (_currentRequestId != requestId) return;
      state = state.copyWith(isLoadingPage: false);
    }
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

  Future<void> goToFirstPage() async {
    await goToPage(1);
  }

  Future<void> goToLastPage() async {
    await goToPage(state.totalPage);
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
          final updatedInterests =
              post.interests.map((interest) {
                if (interest.id == interestId) {
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

          final hasUpdatedInterest = updatedInterests.any(
            (interest) => interest.id == interestId,
          );

          if (hasUpdatedInterest) {
            final newPostUnreadCount = updatedInterests.fold<int>(
              0,
              (sum, interest) => sum + interest.unreadMessageCount,
            );

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
  // Method để reset unread count cho một interest cụ thể khi user vào chat
  void resetInterestUnreadCount(int interestId) {
    final updatedPosts =
        state.interests.map((post) {
          final updatedInterests =
              post.interests.map((interest) {
                if (interest.id == interestId) {
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
                    newMessageIsRead: 1,
                    unreadMessageCount: 0,
                  );
                }
                return interest;
              }).toList();

          final hasUpdatedInterest = updatedInterests.any(
            (interest) => interest.id == interestId,
          );

          if (hasUpdatedInterest) {
            final newPostUnreadCount = updatedInterests.fold<int>(
              0,
              (sum, interest) => sum + interest.unreadMessageCount,
            );

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

    // Tính toán lại tổng unread count từ tất cả posts
    final totalUnreadCount = updatedPosts.fold<int>(
      0,
      (sum, post) => sum + post.unreadMessageCount,
    );

    state = state.copyWith(
      interests: updatedPosts,
      unreadMessageCount: totalUnreadCount,
    );
  }

  void updateSelectedTab(int tabIndex) {
    state = state.copyWith(selectedTab: tabIndex);
  }
}
