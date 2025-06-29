import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/chat_notification.dart';
import 'package:trao_doi_do_app/domain/repositories/multi_websocket_repository.dart';

class ChatNotificationWebSocketState {
  final WebSocketConnectionState connectionState;
  final List<ChatNotification> notifications;
  final WebSocketResponse? lastResponse;
  final String? error;
  final bool isConnecting;

  const ChatNotificationWebSocketState({
    this.connectionState = WebSocketConnectionState.disconnected,
    this.notifications = const [],
    this.lastResponse,
    this.error,
    this.isConnecting = false,
  });

  ChatNotificationWebSocketState copyWith({
    WebSocketConnectionState? connectionState,
    List<ChatNotification>? notifications,
    WebSocketResponse? lastResponse,
    String? error,
    bool? isConnecting,
    int? unreadCount,
    int? interestedPostsUnreadCount,
    int? postsWithInterestsUnreadCount,
  }) {
    return ChatNotificationWebSocketState(
      connectionState: connectionState ?? this.connectionState,
      notifications: notifications ?? this.notifications,
      lastResponse: lastResponse ?? this.lastResponse,
      error: error,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }

  bool get isConnected => connectionState == WebSocketConnectionState.connected;
  bool get isDisconnected =>
      connectionState == WebSocketConnectionState.disconnected;
  bool get hasError => connectionState == WebSocketConnectionState.error;
}

class ChatNotificationWebSocketNotifier
    extends StateNotifier<ChatNotificationWebSocketState> {
  final MultiWebSocketRepository _repository;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _responseSubscription;

  ChatNotificationWebSocketNotifier(this._repository)
    : super(const ChatNotificationWebSocketState()) {
    _listenToConnectionState();
    _listenToChatNotificationResponses();
  }

  void _listenToConnectionState() {
    _connectionSubscription = _repository.connectionStream.listen(
      (connectionState) {
        state = state.copyWith(
          connectionState: connectionState,
          isConnecting: connectionState == WebSocketConnectionState.connecting,
          error:
              connectionState == WebSocketConnectionState.error
                  ? 'Connection error'
                  : null,
        );

        // Clear notifications when disconnected
        if (connectionState == WebSocketConnectionState.disconnected) {
          state = state.copyWith(
            notifications: [],
            unreadCount: 0,
            interestedPostsUnreadCount: 0,
            postsWithInterestsUnreadCount: 0,
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

  void _listenToChatNotificationResponses() {
    _responseSubscription = _repository.chatNotificationResponseStream.listen(
      (response) {
        state = state.copyWith(lastResponse: response);

        switch (response.event) {
          case 'join_noti_room_response':
            break;

          case 'send_message_response':
            if (response.isSuccess && response.data != null) {
              _handleNewMessageNotification(response.data!);
            }
            break;

          case 'pong':
            // Handle ping/pong for keep-alive
            break;

          default:
            // Handle any other notification events
            if (response.data != null) {
              _handleNewChatNotification(response.data!);
            }
        }
      },
      onError: (error) {
        state = state.copyWith(error: 'Response stream error: $error');
      },
    );
  }

  void _handleNewMessageNotification(Map<String, dynamic> data) {}

  void _handleNewChatNotification(Map<String, dynamic> data) {
    try {
      final notification = ChatNotification.fromJson(data);
      final updatedNotifications = [notification, ...state.notifications];
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: 'Error parsing chat notification: $e');
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

    if (state.isConnecting || state.isConnected) {
      return;
    }

    state = state.copyWith(
      isConnecting: true,
      error: null,
      connectionState: WebSocketConnectionState.connecting,
    );

    try {
      await _repository.connectToChatNotification(token);
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        connectionState: WebSocketConnectionState.error,
        error: 'Failed to connect to chat notification: $e',
      );
    }
  }

  Future<void> reconnect(String? token) async {
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect(token);
  }

  Future<void> connectToChatNotification(String? token) async {
    return connect(token);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void markAsRead() {
    state = state.copyWith(
      unreadCount: 0,
      interestedPostsUnreadCount: 0,
      postsWithInterestsUnreadCount: 0,
    );
  }

  void clearAllNotifications() {
    state = state.copyWith(
      notifications: [],
      unreadCount: 0,
      interestedPostsUnreadCount: 0,
      postsWithInterestsUnreadCount: 0,
    );
  }

  void disconnect() {
    _repository.disconnectChatNotification();

    state = state.copyWith(
      connectionState: WebSocketConnectionState.disconnected,
      notifications: [],
      unreadCount: 0,
      interestedPostsUnreadCount: 0,
      postsWithInterestsUnreadCount: 0,
      isConnecting: false,
    );
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _responseSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}
