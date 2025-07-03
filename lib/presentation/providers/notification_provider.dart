import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/notification.dart' as entities;
import 'package:trao_doi_do_app/domain/entities/notification_socket.dart';
import 'package:trao_doi_do_app/domain/usecases/get_notifications_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/mark_notification_read_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/params/notification_query.dart';
import 'package:trao_doi_do_app/presentation/providers/notification_websocket_provider.dart';

class NotificationState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<entities.Notification> apiNotifications;
  final List<NotificationSocket> realtimeNotifications;
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
    this.apiNotifications = const [],
    this.realtimeNotifications = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.unreadCount = 0,
    this.query = const NotificationQuery(),
    this.failure,
    this.hasMoreData = true,
    this.successMessage,
  });

  List<dynamic> get allNotifications {
    return [...realtimeNotifications, ...apiNotifications]..sort((a, b) {
      final aDate =
          a is NotificationSocket
              ? a.createdAt
              : DateTime.parse((a as entities.Notification).createdAt);
      final bDate =
          b is NotificationSocket
              ? b.createdAt
              : DateTime.parse((b as entities.Notification).createdAt);
      return bDate.compareTo(aDate);
    });
  }

  NotificationState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<entities.Notification>? apiNotifications,
    List<NotificationSocket>? realtimeNotifications,
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
      apiNotifications: apiNotifications ?? this.apiNotifications,
      realtimeNotifications:
          realtimeNotifications ?? this.realtimeNotifications,
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
  final Ref _ref;

  NotificationNotifier(
    this._getNotificationsUseCase,
    this._markNotificationReadUseCase,
    this._markAllNotificationsReadUseCase,
    this._ref,
  ) : super(NotificationState()) {
    _setupWebSocketListener();
  }

  void _setupWebSocketListener() {
    _ref.listen<NotificationWebSocketState>(notificationWebSocketProvider, (
      _,
      wsState,
    ) {
      if (wsState.notifications.isNotEmpty) {
        final newRealtimeNotifs =
            wsState.notifications
                .where(
                  (wsNotif) =>
                      !state.realtimeNotifications.any(
                        (n) => n.id == wsNotif.id,
                      ) &&
                      !state.apiNotifications.any((n) => n.id == wsNotif.id),
                )
                .toList();

        if (newRealtimeNotifs.isNotEmpty) {
          final newUnreadCount =
              newRealtimeNotifs.where((n) => !n.isRead).length;
          state = state.copyWith(
            realtimeNotifications: [
              ...state.realtimeNotifications,
              ...newRealtimeNotifs,
            ],
            unreadCount: state.unreadCount + newUnreadCount,
          );
        }
      }
    });
  }

  Future<void> loadNotifications({
    NotificationQuery? newQuery,
    bool refresh = false,
    bool isLoadMore = false,
  }) async {
    if (state.isLoading || state.isLoadingMore) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.apiNotifications.isEmpty;

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
        List<entities.Notification> newNotifications;

        if (isFirstLoad) {
          newNotifications = notificationsResult.notifications;
        } else if (isLoadMore) {
          newNotifications = [
            ...state.apiNotifications,
            ...notificationsResult.notifications,
          ];
        } else {
          newNotifications = state.apiNotifications;
        }

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          apiNotifications: newNotifications,
          currentPage: notificationsResult.totalPage > 0 ? state.query.page : 1,
          totalPage: notificationsResult.totalPage,
          unreadCount: notificationsResult.unreadCount,
          hasMoreData:
              notificationsResult.totalPage > 0 &&
              state.query.page < notificationsResult.totalPage,
        );

        // Clean up realtime notifications that are now in API
        if (refresh) {
          final apiIds = newNotifications.map((n) => n.id).toSet();
          final remainingRealtime =
              state.realtimeNotifications
                  .where((n) => !apiIds.contains(n.id))
                  .toList();

          if (remainingRealtime.length != state.realtimeNotifications.length) {
            state = state.copyWith(realtimeNotifications: remainingRealtime);
          }
        }
      },
    );
  }

  Future<void> markAsRead(int notificationId) async {
    // Check in realtime notifications first
    final realtimeIndex = state.realtimeNotifications.indexWhere(
      (n) => n.id == notificationId,
    );
    if (realtimeIndex != -1) {
      final updatedRealtime = List<NotificationSocket>.from(
        state.realtimeNotifications,
      );
      updatedRealtime[realtimeIndex] = updatedRealtime[realtimeIndex].copyWith(
        isRead: true,
      );

      state = state.copyWith(
        realtimeNotifications: updatedRealtime,
        unreadCount: state.unreadCount - 1,
      );
    }

    // Check in API notifications
    final apiIndex = state.apiNotifications.indexWhere(
      (n) => n.id == notificationId,
    );
    if (apiIndex != -1) {
      final updatedApi = List<entities.Notification>.from(
        state.apiNotifications,
      );
      updatedApi[apiIndex] = updatedApi[apiIndex].copyWith(isRead: true);

      state = state.copyWith(
        apiNotifications: updatedApi,
        unreadCount: state.unreadCount - 1,
      );
    }

    // Call API to mark as read
    final result = await _markNotificationReadUseCase(notificationId);
    result.fold(
      (failure) => state = state.copyWith(failure: failure),
      (_) => loadUnreadCount(),
    );
  }

  Future<void> markAllAsRead() async {
    // Mark all realtime as read
    final updatedRealtime =
        state.realtimeNotifications
            .map((n) => n.copyWith(isRead: true))
            .toList();

    // Mark all API as read
    final updatedApi =
        state.apiNotifications.map((n) => n.copyWith(isRead: true)).toList();

    state = state.copyWith(
      realtimeNotifications: updatedRealtime,
      apiNotifications: updatedApi,
      unreadCount: 0,
    );

    // Call API
    final result = await _markAllNotificationsReadUseCase();
    result.fold(
      (failure) => state = state.copyWith(failure: failure),
      (_) => loadUnreadCount(),
    );
  }

  Future<void> loadUnreadCount() async {
    final result = await _getNotificationsUseCase(
      NotificationQuery(page: 1, limit: 1),
    );
    result.fold(
      (failure) => state = state.copyWith(failure: failure),
      (result) => state = state.copyWith(unreadCount: result.unreadCount),
    );
  }

  void loadMore() => loadNotifications(isLoadMore: true);
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
    await loadUnreadCount();
  }

  void clearSuccessMessage() => state = state.copyWith(successMessage: null);
}
