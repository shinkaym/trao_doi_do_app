import 'dart:async';
import 'package:flutter_debouncer/flutter_debouncer.dart';
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
  final DateTime? lastLoadTime;
  final Set<int> loadingPages;

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
    this.lastLoadTime,
    this.loadingPages = const {},
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
    DateTime? lastLoadTime,
    Set<int>? loadingPages,
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
      lastLoadTime: lastLoadTime ?? this.lastLoadTime,
      loadingPages: loadingPages ?? this.loadingPages,
    );
  }

  bool get canLoadMore => hasMoreData && !isLoadingMore && !isLoading;
}

class MessagesListNotifier extends StateNotifier<MessagesListState> {
  final GetMessagesUseCase _getMessagesUseCase;
  final MarkAllMessagesReadUseCase _markAllMessagesReadUseCase;

  // Debouncing and optimization
  final Debouncer _loadMoreDebouncer = Debouncer();
  static const Duration _loadMoreDebounce = Duration(milliseconds: 300);
  static const Duration _minTimeBetweenLoads = Duration(milliseconds: 500);
  final Debouncer _searchDebouncer = Debouncer();

  MessagesListNotifier(
    this._getMessagesUseCase,
    this._markAllMessagesReadUseCase,
    int interestID,
  ) : super(MessagesListState(query: MessagesQuery(interestID: interestID)));

  @override
  void dispose() {
    _loadMoreDebouncer.cancel();
    _searchDebouncer.cancel();
    super.dispose();
  }

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
        // Efficiently update all messages to read status
        final updatedMessages =
            state.messages.map((message) {
              return message.isRead == 0
                  ? message.copyWith(isRead: 1)
                  : message;
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

  Future<void> loadMessages({
    MessagesQuery? newQuery,
    bool refresh = false,
    bool isLoadMore = false,
  }) async {
    // Prevent multiple simultaneous loads
    if (!refresh && !isLoadMore && state.isLoading) return;
    if (isLoadMore && !state.canLoadMore) return;

    // Debounce load more requests
    if (isLoadMore && _shouldDebounceLoadMore()) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.messages.isEmpty;
    final nextPage = isLoadMore ? state.currentPage + 1 : 1;

    // Update loading state
    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
        currentPage: 1,
        loadingPages: {1},
      );
    } else if (isLoadMore) {
      state = state.copyWith(
        isLoadingMore: true,
        failure: null,
        loadingPages: {...state.loadingPages, nextPage},
      );
    }

    try {
      final queryToUse =
          isLoadMore
              ? state.query.copyWith(page: nextPage)
              : state.query.copyWith(page: 1);

      final result = await _getMessagesUseCase(queryToUse);

      await result.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            failure: failure,
            loadingPages: state.loadingPages..remove(nextPage),
          );
        },
        (messagesResult) async {
          await _handleLoadSuccess(
            messagesResult,
            isFirstLoad,
            isLoadMore,
            nextPage,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        loadingPages: state.loadingPages..remove(nextPage),
      );
    }
  }

  bool _shouldDebounceLoadMore() {
    final lastLoad = state.lastLoadTime;
    if (lastLoad == null) return false;

    final timeSinceLastLoad = DateTime.now().difference(lastLoad);
    return timeSinceLastLoad < _minTimeBetweenLoads;
  }

  Future<void> _handleLoadSuccess(
    dynamic messagesResult,
    bool isFirstLoad,
    bool isLoadMore,
    int pageLoaded,
  ) async {
    final newMessages = messagesResult.messages as List<Message>;
    final hasMoreData = newMessages.length >= state.query.limit;

    List<Message> finalMessages;
    int newCurrentPage;

    if (isFirstLoad) {
      // For first load, reverse to show newest at bottom
      finalMessages = newMessages.reversed.toList();
      newCurrentPage = 1;
    } else if (isLoadMore) {
      // For load more, add older messages at the beginning
      // But keep them in the order they should appear (older first)
      final olderMessages = newMessages.reversed.toList();
      finalMessages = [...olderMessages, ...state.messages];
      newCurrentPage = pageLoaded;
    } else {
      finalMessages = state.messages;
      newCurrentPage = state.currentPage;
    }

    // Remove duplicates while preserving order
    finalMessages = _removeDuplicateMessages(finalMessages);

    state = state.copyWith(
      isLoading: false,
      isLoadingMore: false,
      messages: finalMessages,
      currentPage: newCurrentPage,
      hasMoreData: hasMoreData,
      failure: null,
      lastLoadTime: DateTime.now(),
      loadingPages: state.loadingPages..remove(pageLoaded),
    );
  }

  List<Message> _removeDuplicateMessages(List<Message> messages) {
    final seen = <int>{};
    final uniqueMessages = <Message>[];

    for (final message in messages) {
      if (!seen.contains(message.id)) {
        seen.add(message.id);
        uniqueMessages.add(message);
      }
    }

    return uniqueMessages;
  }

  Future<void> loadMore() async {
    _loadMoreDebouncer.debounce(
      duration: _loadMoreDebounce,
      onDebounce: () {
        if (mounted && state.canLoadMore) {
          loadMessages(isLoadMore: true);
        }
      },
    );
  }

  Future<void> refresh() async {
    await loadMessages(refresh: true);
  }

  void addNewMessage(Message message) {
    if (message.interestID != state.query.interestID) return;

    // Check if message already exists to prevent duplicates
    final messageExists = state.messages.any((m) => m.id == message.id);
    if (messageExists) return;

    // Add new message at the end (most recent)
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
  }

  void clearMessages() {
    state = state.copyWith(
      messages: [],
      currentPage: 1,
      hasMoreData: true,
      failure: null,
      lastLoadTime: null,
      loadingPages: {},
    );
  }

  int get unreadCount {
    return state.messages.where((message) => message.isRead == 0).length;
  }

  void clearError() {
    if (state.failure != null) {
      state = state.copyWith(failure: null);
    }
  }
}
