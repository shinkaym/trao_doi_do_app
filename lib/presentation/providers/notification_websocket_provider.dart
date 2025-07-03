import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  const NotificationWebSocketState({
    this.connectionState = WebSocketConnectionState.disconnected,
    this.notifications = const [],
    this.lastResponse,
    this.error,
    this.isConnecting = false,
  });

  bool get isConnected => connectionState == WebSocketConnectionState.connected;
  bool get isDisconnected =>
      connectionState == WebSocketConnectionState.disconnected;
  bool get hasError => connectionState == WebSocketConnectionState.error;

  NotificationWebSocketState copyWith({
    WebSocketConnectionState? connectionState,
    List<NotificationSocket>? notifications,
    WebSocketResponse? lastResponse,
    String? error,
    bool? isConnecting,
  }) {
    return NotificationWebSocketState(
      connectionState: connectionState ?? this.connectionState,
      notifications: notifications ?? this.notifications,
      lastResponse: lastResponse ?? this.lastResponse,
      error: error,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }
}

class NotificationWebSocketNotifier
    extends StateNotifier<NotificationWebSocketState> {
  final MultiWebSocketRepository _repository;
  final AudioPlayer _audioPlayer;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _responseSubscription;

  NotificationWebSocketNotifier(this._repository)
    : _audioPlayer = AudioPlayer(),
      super(const NotificationWebSocketState()) {
    _listenToConnectionState();
    _listenToNotificationResponses();
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
    _responseSubscription = _repository.notificationResponseStream.listen(
      (response) {
        state = state.copyWith(lastResponse: response);

        if (response.event == 'receive_noti_response' &&
            response.isSuccess &&
            response.data != null) {
          try {
            final notification = NotificationSocket.fromJson(response.data!);
            final updatedNotifications = [notification, ...state.notifications];
            state = state.copyWith(notifications: updatedNotifications);
            _playNotificationSound();
          } catch (e) {
            state = state.copyWith(error: 'Error parsing notification: $e');
          }
        }
      },
      onError: (error) {
        state = state.copyWith(error: 'Response stream error: $error');
      },
    );
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.stop(); // Dừng âm thanh hiện tại nếu có
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));

      // Hoặc nếu bạn muốn phát từ URL:
      // await _audioPlayer.play(UrlSource('https://example.com/sound.mp3'));
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  Future<void> connect(String? token) async {
    if (token == null || state.isConnecting || state.isConnected) return;

    state = state.copyWith(
      isConnecting: true,
      error: null,
      connectionState: WebSocketConnectionState.connecting,
    );

    try {
      await _repository.connectToNotification(token);
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        connectionState: WebSocketConnectionState.error,
        error: 'Failed to connect: $e',
      );
    }
  }

  void disconnect() {
    _repository.disconnectNotification();
    state = state.copyWith(
      connectionState: WebSocketConnectionState.disconnected,
      notifications: [],
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
