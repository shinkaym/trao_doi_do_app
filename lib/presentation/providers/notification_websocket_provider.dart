import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/repositories/multi_websocket_repository.dart';

class NotificationWebSocketState {
  final WebSocketConnectionState connectionState;
  final List<WebSocketResponse> notifications;
  final int unreadCount;

  const NotificationWebSocketState({
    this.connectionState = WebSocketConnectionState.disconnected,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationWebSocketState copyWith({
    WebSocketConnectionState? connectionState,
    List<WebSocketResponse>? notifications,
    int? unreadCount,
  }) {
    return NotificationWebSocketState(
      connectionState: connectionState ?? this.connectionState,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// Notification Provider
class NotificationWebSocketNotifier
    extends StateNotifier<NotificationWebSocketState> {
  final MultiWebSocketRepository _repository;

  NotificationWebSocketNotifier(this._repository)
    : super(const NotificationWebSocketState()) {
    _listenToNotificationResponses();
  }

  void _listenToNotificationResponses() {
    _repository.notificationResponseStream.listen((response) {
      switch (response.event) {
        case 'new_notification':
        case 'message_notification':
          final updatedNotifications = [...state.notifications, response];
          state = state.copyWith(
            notifications: updatedNotifications,
            unreadCount: state.unreadCount + 1,
          );
          break;
        default:
          break;
      }
    });
  }

  Future<void> connect(String? token) async {
    await _repository.connectToNotification(token);
  }

  void markAsRead() {
    state = state.copyWith(unreadCount: 0);
  }

  void disconnect() {
    _repository.disconnectNotification();
  }
}
