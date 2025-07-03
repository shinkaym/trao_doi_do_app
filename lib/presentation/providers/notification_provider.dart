import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/notification.dart';
import 'package:trao_doi_do_app/domain/usecases/get_notifications_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/mark_notification_read_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/params/notification_query.dart';

class NotificationState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Notification> notifications;
  final int currentPage;
  final int totalPage;
  final int unreadCount;
  final NotificationQuery query;
  final Failure? failure;
  final bool hasMoreData;
  final String? successMessage;

  NotificationState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.notifications = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.unreadCount = 0,
    this.query = const NotificationQuery(),
    this.failure,
    this.hasMoreData = true,
    this.successMessage,
  });

  NotificationState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Notification>? notifications,
    int? currentPage,
    int? totalPage,
    int? unreadCount,
    NotificationQuery? query,
    Failure? failure,
    bool? hasMoreData,
    String? successMessage,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      unreadCount: unreadCount ?? this.unreadCount,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      successMessage: successMessage,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;

  NotificationNotifier(
    this._getNotificationsUseCase,
    this._markNotificationReadUseCase,
    this._markAllNotificationsReadUseCase,
  ) : super(NotificationState());

  Future<void> loadNotifications({
    NotificationQuery? newQuery,
    bool refresh = false,
    bool isLoadMore = false,
  }) async {
    if (state.isLoading || state.isLoadingMore) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.notifications.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
      );
    } else if (isLoadMore) {
      if (!state.hasMoreData || state.currentPage >= state.totalPage) return;

      state = state.copyWith(
        isLoadingMore: true,
        failure: null,
        query: query.copyWith(page: state.currentPage + 1),
      );
    }

    final result = await _getNotificationsUseCase(state.query);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            failure: failure,
          ),
      (notificationsResult) {
        List<Notification> newNotifications;

        if (isFirstLoad) {
          newNotifications = notificationsResult.notifications;
        } else if (isLoadMore) {
          newNotifications = [
            ...state.notifications,
            ...notificationsResult.notifications,
          ];
        } else {
          newNotifications = state.notifications;
        }

        final actualTotalPage = notificationsResult.totalPage;
        final actualCurrentPage = actualTotalPage > 0 ? state.query.page : 1;
        final actualHasMoreData =
            actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          notifications: newNotifications,
          currentPage: actualCurrentPage,
          totalPage: actualTotalPage,
          unreadCount: notificationsResult.unreadCount,
          hasMoreData: actualHasMoreData,
        );
      },
    );
  }

  Future<void> markAsRead(int notificationID) async {
    final result = await _markNotificationReadUseCase(notificationID);

    result.fold((failure) => state = state.copyWith(failure: failure), (_) {
      // Cập nhật trạng thái đã đọc cho notification
      final updatedNotifications =
          state.notifications.map((notification) {
            if (notification.id == notificationID && !notification.isRead) {
              return Notification(
                id: notification.id,
                content: notification.content,
                createdAt: notification.createdAt,
                isRead: true, // Đánh dấu đã đọc
                receiverID: notification.receiverID,
                receiverName: notification.receiverName,
                senderID: notification.senderID,
                senderName: notification.senderName,
                targetID: notification.targetID,
                targetType: notification.targetType,
                type: notification.type,
              );
            }
            return notification;
          }).toList();

      // Giảm số lượng thông báo chưa đọc
      final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        successMessage: 'Đã đánh dấu thông báo đã đọc',
      );
    });
  }

  Future<void> markAllAsRead() async {
    final result = await _markAllNotificationsReadUseCase();

    result.fold((failure) => state = state.copyWith(failure: failure), (_) {
      // Cập nhật tất cả notifications thành đã đọc
      final updatedNotifications =
          state.notifications.map((notification) {
            return Notification(
              id: notification.id,
              content: notification.content,
              createdAt: notification.createdAt,
              isRead: true, // Đánh dấu tất cả đã đọc
              receiverID: notification.receiverID,
              receiverName: notification.receiverName,
              senderID: notification.senderID,
              senderName: notification.senderName,
              targetID: notification.targetID,
              targetType: notification.targetType,
              type: notification.type,
            );
          }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0, // Reset về 0
        successMessage: 'Đã đánh dấu tất cả thông báo đã đọc',
      );
    });
  }

  void loadMore() {
    loadNotifications(isLoadMore: true);
  }

  void refresh() {
    loadNotifications(refresh: true);
  }

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
}
