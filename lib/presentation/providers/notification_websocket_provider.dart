import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/notification_socket.dart';
import 'package:trao_doi_do_app/domain/repositories/multi_websocket_repository.dart';

class NotificationWebSocketState {
  final WebSocketConnectionState connectionState;
  final List<NotificationSocket> notifications;
  final WebSocketResponse? lastResponse;
  final String? error;
  final bool isConnecting;
  final int unreadCount;

  const NotificationWebSocketState({
    this.connectionState = WebSocketConnectionState.disconnected,
    this.notifications = const [],
    this.lastResponse,
    this.error,
    this.isConnecting = false,
    this.unreadCount = 0,
  });

  NotificationWebSocketState copyWith({
    WebSocketConnectionState? connectionState,
    List<NotificationSocket>? notifications,
    WebSocketResponse? lastResponse,
    String? error,
    bool? isConnecting,
    int? unreadCount,
  }) {
    return NotificationWebSocketState(
      connectionState: connectionState ?? this.connectionState,
      notifications: notifications ?? this.notifications,
      lastResponse: lastResponse ?? this.lastResponse,
      error: error,
      isConnecting: isConnecting ?? this.isConnecting,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  bool get isConnected => connectionState == WebSocketConnectionState.connected;
  bool get isDisconnected => connectionState == WebSocketConnectionState.disconnected;
  bool get hasError => connectionState == WebSocketConnectionState.error;
  bool get hasUnreadNotifications => unreadCount > 0;

  // Filter methods
  List<NotificationSocket> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  List<NotificationSocket> get normalNotifications =>
      notifications.where((n) => n.isNormalType).toList();

  List<NotificationSocket> get systemNotifications =>
      notifications.where((n) => n.isSystemType).toList();

  List<NotificationSocket> get interestNotifications =>
      notifications.where((n) => n.isInterestType).toList();

  List<NotificationSocket> get postNotifications =>
      notifications.where((n) => n.isPostType).toList();

  List<NotificationSocket> get appointmentNotifications =>
      notifications.where((n) => n.isAppointmentType).toList();
}

class NotificationWebSocketNotifier extends StateNotifier<NotificationWebSocketState> {
  final MultiWebSocketRepository _repository;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _responseSubscription;

  NotificationWebSocketNotifier(this._repository)
      : super(const NotificationWebSocketState()) {
    _listenToConnectionState();
    _listenToNotificationResponses();
  }

  // ✅ Expose notification response stream directly
  Stream<WebSocketResponse> get notificationResponseStream =>
      _repository.notificationResponseStream;

  void _listenToConnectionState() {
    _connectionSubscription = _repository.connectionStream.listen(
      (connectionState) {
        state = state.copyWith(
          connectionState: connectionState,
          isConnecting: connectionState == WebSocketConnectionState.connecting,
          error: connectionState == WebSocketConnectionState.error
              ? 'Connection error'
              : null,
        );

        // Clear notifications when disconnected
        if (connectionState == WebSocketConnectionState.disconnected) {
          state = state.copyWith(
            notifications: [],
            unreadCount: 0,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          connectionState: WebSocketConnectionState.error,
          error: 'Connection stream error: $error',
          isConnecting: false,
        );
      },
    );
  }

  void _listenToNotificationResponses() {
    // ✅ Listen to notification-specific responses only
    _responseSubscription = _repository.notificationResponseStream.listen(
      (response) {
        state = state.copyWith(lastResponse: response);

        // ✅ Debug logging
        print('🔔 Notification Provider - Received response: ${response.event} from ${response.sourceChannel}');

        switch (response.event) {
          case 'receive_noti_response':
            if (response.isSuccess && response.data != null) {
              print('🔔 New notification received: ${response.data}');
              _handleNewNotification(response.data!);
            } else {
              state = state.copyWith(
                error: response.error ?? 'Failed to receive notification',
              );
            }
            break;

          case 'pong':
            // Handle ping/pong for keep-alive
            break;

          default:
            print('🔍 Unhandled notification event: ${response.event}');
        }
      },
      onError: (error) {
        state = state.copyWith(error: 'Response stream error: $error');
        print('❌ Notification response stream error: $error');
      },
    );
  }

  void _handleNewNotification(Map<String, dynamic> data) {
    try {
      final notification = NotificationSocket.fromJson(data);
      final updatedNotifications = [notification, ...state.notifications];

      // Calculate unread count
      final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      );

      print('✅ Added new notification to state - Unread: $newUnreadCount');
    } catch (e) {
      print('❌ Error parsing notification: $e');
      state = state.copyWith(error: 'Error parsing notification: $e');
    }
  }

  Future<void> connect(String? token) async {
    if (token == null) {
      state = state.copyWith(
        error: 'Cannot connect: no auth token',
        connectionState: WebSocketConnectionState.error,
      );
      return;
    }

    if (state.isConnecting) {
      print('⚠️ Already connecting to notification...');
      return;
    }

    if (state.isConnected) {
      print('✅ Already connected to notification');
      return;
    }

    // ✅ SET CONNECTING STATE IMMEDIATELY
    state = state.copyWith(
      isConnecting: true,
      error: null,
      connectionState: WebSocketConnectionState.connecting,
    );

    print('🔔 Connecting to notification WebSocket...');

    try {
      await _repository.connectToNotification(token);
      print('✅ Notification connection initiated');
      // Connection state will be updated via stream listener
    } catch (e) {
      print('❌ Notification connection failed: $e');
      state = state.copyWith(
        isConnecting: false,
        connectionState: WebSocketConnectionState.error,
        error: 'Failed to connect to notification: $e',
      );
    }
  }

  // ✅ Method for force reconnect
  Future<void> reconnect(String? token) async {
    print('🔄 Reconnecting notification WebSocket...');
    // Disconnect first
    disconnect();

    // Wait a bit before reconnecting
    await Future.delayed(const Duration(milliseconds: 500));

    // Connect again
    await connect(token);
  }

  Future<void> connectToNotification(String? token) async {
    return connect(token);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void markNotificationAsRead(int notificationId) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );

    print('✅ Marked notification $notificationId as read - Unread: $newUnreadCount');
  }

  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    );

    print('✅ Marked all notifications as read');
  }

  void clearAllNotifications() {
    state = state.copyWith(
      notifications: [],
      unreadCount: 0,
    );

    print('✅ Cleared all notifications');
  }

  void removeNotification(int notificationId) {
    final updatedNotifications = state.notifications
        .where((notification) => notification.id != notificationId)
        .toList();

    final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );

    print('✅ Removed notification $notificationId - Unread: $newUnreadCount');
  }

  void disconnect() {
    print('🔔 Disconnecting from notification WebSocket...');
    _repository.disconnectNotification();

    state = state.copyWith(
      connectionState: WebSocketConnectionState.disconnected,
      notifications: [],
      unreadCount: 0,
      isConnecting: false,
    );
  }

  @override
  void dispose() {
    print('🗑️ Disposing Notification WebSocket Provider');
    _connectionSubscription?.cancel();
    _responseSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}