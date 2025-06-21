import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/message.dart';
import 'package:trao_doi_do_app/domain/usecases/params/message_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_messages_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/mark_all_messages_read_usecase.dart';

class MessagesListState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isMarkingAllRead;
  final List<Message> messages;
  final int currentPage;
  final MessagesQuery query;
  final Failure? failure;
  final bool hasMoreData;
  final String? markAllReadResult;

  MessagesListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMarkingAllRead = false,
    this.messages = const [],
    this.currentPage = 1,
    required this.query,
    this.failure,
    this.hasMoreData = true,
    this.markAllReadResult,
  });

  MessagesListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMarkingAllRead,
    List<Message>? messages,
    int? currentPage,
    MessagesQuery? query,
    Failure? failure,
    bool? hasMoreData,
    String? markAllReadResult,
  }) {
    return MessagesListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
      messages: messages ?? this.messages,
      currentPage: currentPage ?? this.currentPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      markAllReadResult: markAllReadResult,
    );
  }
}

class MessagesListNotifier extends StateNotifier<MessagesListState> {
  final GetMessagesUseCase _getMessagesUseCase;
  final MarkAllMessagesReadUseCase _markAllMessagesReadUseCase;

  MessagesListNotifier(
    this._getMessagesUseCase,
    this._markAllMessagesReadUseCase,
    int interestID,
  ) : super(MessagesListState(query: MessagesQuery(interestID: interestID)));

  // Đánh dấu đã đọc tất cả tin nhắn
  Future<void> markAllAsRead() async {
    if (state.isMarkingAllRead) return;

    state = state.copyWith(
      isMarkingAllRead: true,
      failure: null,
      markAllReadResult: null,
    );

    final result = await _markAllMessagesReadUseCase(state.query.interestID);

    result.fold(
      (failure) =>
          state = state.copyWith(isMarkingAllRead: false, failure: failure),
      (resultMessage) {
        // Cập nhật tất cả tin nhắn thành đã đọc
        final updatedMessages =
            state.messages.map((message) {
              return message.copyWith(isRead: 1);
            }).toList();

        state = state.copyWith(
          isMarkingAllRead: false,
          messages: updatedMessages,
          markAllReadResult: resultMessage,
          failure: null,
        );
      },
    );
  }

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
        currentPage: 1,
      );
    } else if (isLoadMore) {
      if (!state.hasMoreData) return;

      state = state.copyWith(
        isLoadingMore: true,
        failure: null,
        query: query.copyWith(page: state.currentPage + 1),
      );
    }

    final result = await _getMessagesUseCase(state.query);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            failure: failure,
          ),
      (messagesResult) {
        List<Message> newMessages;
        int newCurrentPage;

        if (isFirstLoad) {
          newMessages = messagesResult.messages.reversed.toList();
          newCurrentPage = 1;
        } else if (isLoadMore) {
          final oldMessages = messagesResult.messages.reversed.toList();
          newMessages = [...oldMessages, ...state.messages];
          newCurrentPage = state.currentPage + 1;
        } else {
          newMessages = state.messages;
          newCurrentPage = state.currentPage;
        }

        final hasMoreData = messagesResult.messages.length >= state.query.limit;

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          messages: newMessages,
          currentPage: newCurrentPage,
          hasMoreData: hasMoreData,
          failure: null,
        );
      },
    );
  }

  Future<void> searchMessages(String? search) async {
    final newQuery = state.query.copyWith(search: search, page: 1);
    await loadMessages(newQuery: newQuery, refresh: true);
  }

  Future<void> loadMore() async {
    await loadMessages(isLoadMore: true);
  }

  Future<void> refresh() async {
    await loadMessages(refresh: true);
  }

  void addNewMessage(Message message) {
    if (message.interestID == state.query.interestID) {
      final updatedMessages = [...state.messages, message];
      state = state.copyWith(messages: updatedMessages);
    }
  }

  void markMessageAsRead(int messageId) {
    final updatedMessages =
        state.messages.map((message) {
          if (message.id == messageId) {
            return message.copyWith(isRead: 1);
          }
          return message;
        }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  int get unreadCount {
    return state.messages.where((message) => message.isRead == 0).length;
  }
}
