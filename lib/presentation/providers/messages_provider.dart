import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/message.dart';
import 'package:trao_doi_do_app/domain/usecases/params/message_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_messages_usecase.dart';

class MessagesListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Message> messages;
  final int currentPage;
  final MessagesQuery query;
  final Failure? failure;
  final bool hasMoreData;

  MessagesListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.messages = const [],
    this.currentPage = 1,
    required this.query,
    this.failure,
    this.hasMoreData = true,
  });

  MessagesListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Message>? messages,
    int? currentPage,
    MessagesQuery? query,
    Failure? failure,
    bool? hasMoreData,
  }) {
    return MessagesListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      messages: messages ?? this.messages,
      currentPage: currentPage ?? this.currentPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class MessagesListNotifier extends StateNotifier<MessagesListState> {
  final GetMessagesUseCase _getMessagesUseCase;

  MessagesListNotifier(this._getMessagesUseCase, int interestID)
    : super(MessagesListState(query: MessagesQuery(interestID: interestID)));

  // Load messages với các tùy chọn khác nhau
  Future<void> loadMessages({
    MessagesQuery? newQuery,
    bool refresh = false,
    bool isLoadMore = false,
  }) async {
    if (state.isLoading || state.isLoadingMore) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.messages.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
      );
    } else if (isLoadMore) {
      if (!state.hasMoreData) return;

      state = state.copyWith(
        isLoadingMore: true,
        failure: null,
        query: query.copyWith(page: state.currentPage + 1),
      );
    }

    final result = await _getMessagesUseCase(query);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            failure: failure,
          ),
      (messagesResult) {
        List<Message> newMessages;

        if (isFirstLoad) {
          newMessages = messagesResult.messages;
        } else if (isLoadMore) {
          newMessages = [...state.messages, ...messagesResult.messages];
        } else {
          newMessages = state.messages;
        }

        final actualCurrentPage = state.query.page;
        final actualHasMoreData =
            messagesResult.messages.length >= state.query.limit;

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          messages: newMessages,
          currentPage: actualCurrentPage,
          hasMoreData: actualHasMoreData,
        );
      },
    );
  }

  // Tìm kiếm tin nhắn
  void searchMessages(String? search) {
    final newQuery = state.query.copyWith(search: search, page: 1);
    loadMessages(newQuery: newQuery, refresh: true);
  }

  // Load more messages (cho infinite scroll)
  void loadMore() {
    loadMessages(isLoadMore: true);
  }

  // Refresh messages
  void refresh() {
    loadMessages(refresh: true);
  }

  // Thêm tin nhắn mới vào đầu danh sách (khi có tin nhắn real-time)
  void addNewMessage(Message message) {
    if (message.interestID == state.query.interestID) {
      final updatedMessages = [message, ...state.messages];
      state = state.copyWith(messages: updatedMessages);
    }
  }

  // Cập nhật trạng thái đã đọc của tin nhắn
  void markMessageAsRead(int messageId) {
    final updatedMessages =
        state.messages.map((message) {
          if (message.id == messageId) {
            return Message(
              id: message.id,
              interestID: message.interestID,
              senderID: message.senderID,
              receiverID: message.receiverID,
              message: message.message,
              isRead: 1, // Mark as read
              createdAt: message.createdAt,
            );
          }
          return message;
        }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  // Đếm số tin nhắn chưa đọc
  int get unreadCount {
    return state.messages.where((message) => message.isRead == 0).length;
  }
}
