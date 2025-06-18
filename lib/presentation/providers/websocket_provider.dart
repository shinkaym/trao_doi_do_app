import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/message_socket.dart';
import 'package:trao_doi_do_app/domain/entities/chat_notification.dart';
import 'package:trao_doi_do_app/domain/usecases/websocket_usecases.dart';

class WebSocketState {
  final WebSocketConnectionState connectionState;
  final List<MessageSocket> messages;
  final List<ChatNotification> notifications;
  final WebSocketResponse? lastResponse;
  final String? error;
  final bool isConnecting;
  final String? currentRoomID;

  const WebSocketState({
    this.connectionState = WebSocketConnectionState.disconnected,
    this.messages = const [],
    this.notifications = const [],
    this.lastResponse,
    this.error,
    this.isConnecting = false,
    this.currentRoomID,
  });

  WebSocketState copyWith({
    WebSocketConnectionState? connectionState,
    List<MessageSocket>? messages,
    List<ChatNotification>? notifications,
    WebSocketResponse? lastResponse,
    String? error,
    bool? isConnecting,
    String? currentRoomID,
  }) {
    return WebSocketState(
      connectionState: connectionState ?? this.connectionState,
      messages: messages ?? this.messages,
      notifications: notifications ?? this.notifications,
      lastResponse: lastResponse ?? this.lastResponse,
      error: error,
      isConnecting: isConnecting ?? this.isConnecting,
      currentRoomID: currentRoomID ?? this.currentRoomID,
    );
  }

  bool get isConnected => connectionState == WebSocketConnectionState.connected;
  bool get isDisconnected =>
      connectionState == WebSocketConnectionState.disconnected;
  bool get hasError => connectionState == WebSocketConnectionState.error;
}

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  final ConnectToChatUseCase _connectToChatUseCase;
  final ConnectToNotificationUseCase _connectToNotificationUseCase;
  final DisconnectWebSocketUseCase _disconnectUseCase;
  final JoinRoomUseCase _joinRoomUseCase;
  final LeftRoomUseCase _leftRoomUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final GetWebSocketResponseStreamUseCase _getResponseStreamUseCase;
  final GetWebSocketConnectionStreamUseCase _getConnectionStreamUseCase;

  StreamSubscription? _connectionSubscription;
  StreamSubscription? _responseSubscription;

  WebSocketNotifier(
    this._connectToChatUseCase,
    this._connectToNotificationUseCase,
    this._disconnectUseCase,
    this._joinRoomUseCase,
    this._leftRoomUseCase,
    this._sendMessageUseCase,
    this._getResponseStreamUseCase,
    this._getConnectionStreamUseCase,
  ) : super(const WebSocketState()) {
    _initializeStreams();
  }

  void _initializeStreams() {
    print('🎯 Initializing WebSocket streams...');
    _listenToConnectionStream();
    _listenToResponseStream();
  }

  void _listenToConnectionStream() {
    _connectionSubscription?.cancel();

    print('👂 Setting up connection stream listener...');
    _connectionSubscription = _getConnectionStreamUseCase().listen(
      (connectionState) {
        print('🔄 Connection state from stream: ${connectionState.toString()}');

        // Always update state when connection state changes
        state = state.copyWith(
          connectionState: connectionState,
          isConnecting: connectionState == WebSocketConnectionState.connecting,
          error:
              connectionState == WebSocketConnectionState.error
                  ? 'Connection failed'
                  : null,
        );

        print(
          '🔄 WebSocket state updated: ${connectionState.toString()}, isConnecting: ${state.isConnecting}',
        );
      },
      onError: (error) {
        print('❌ Connection stream error: $error');
        state = state.copyWith(
          connectionState: WebSocketConnectionState.error,
          isConnecting: false,
          error: 'Connection stream error: $error',
        );
      },
      onDone: () {
        print('✅ Connection stream completed');
      },
    );
  }

  void _listenToResponseStream() {
    _responseSubscription?.cancel();

    print('👂 Setting up response stream listener...');
    _responseSubscription = _getResponseStreamUseCase().listen(
      (response) {
        print('📨 Response received: ${response.event}');
        state = state.copyWith(lastResponse: response);
        _handleWebSocketResponse(response);
      },
      onError: (error) {
        print('❌ Response stream error: $error');
        state = state.copyWith(error: 'Response stream error: $error');
      },
      onDone: () {
        print('✅ Response stream completed');
      },
    );
  }

  void _handleWebSocketResponse(WebSocketResponse response) {
    print('🔄 Handling WebSocket response: ${response.event}');

    switch (response.event) {
      case 'join_room_response':
        if (response.isSuccess && response.data != null) {
          final roomID = response.data!['roomID'] as String?;
          state = state.copyWith(currentRoomID: roomID);
          print('✅ Successfully joined room: $roomID');
        } else {
          state = state.copyWith(
            error: response.error ?? 'Failed to join room',
          );
          print('❌ Failed to join room: ${response.error}');
        }
        break;

      case 'send_message_response':
        print('📨 Processing send_message_response: ${response.data}');
        if (response.isSuccess && response.data != null) {
          print('✅ Message sent successfully');
          _handleNewMessage(response.data!);
        } else {
          print('❌ Failed to send message: ${response.error}');
          state = state.copyWith(
            error: response.error ?? 'Failed to send message',
          );
        }
        break;

      case 'left_room_response':
        if (response.isSuccess) {
          print('✅ Successfully left room');
          state = state.copyWith(messages: [], currentRoomID: null);
        }
        break;

      case 'join_noti_room_response':
        if (response.isSuccess && response.data != null) {
          final roomID = response.data!['roomID'] as String?;
          print('✅ Successfully joined notification room: $roomID');
        }
        break;

      case 'pong':
        print('💓 Received pong');
        break;

      default:
        print('❓ Unhandled WebSocket event: ${response.event}');
        // Still store the response for debugging
        state = state.copyWith(lastResponse: response);
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final message = MessageSocket.fromJson(data);
      final updatedMessages = [message, ...state.messages];
      state = state.copyWith(messages: updatedMessages);
      print('📨 Added new message to state: ${message.message}');
    } catch (e) {
      print('❌ Error parsing message: $e');
      state = state.copyWith(error: 'Error parsing message: $e');
    }
  }

  void _handleNewNotification(Map<String, dynamic> data) {
    try {
      final notification = ChatNotification.fromJson(data);
      final updatedNotifications = [...state.notifications, notification];
      state = state.copyWith(notifications: updatedNotifications);
      print('🔔 Added new notification to state');
    } catch (e) {
      print('❌ Error parsing notification: $e');
      state = state.copyWith(error: 'Error parsing notification: $e');
    }
  }

  Future<void> connectToChat(String? token) async {
    if (state.isConnecting) {
      print('⚠️ Connection already in progress, skipping...');
      return;
    }

    if (state.isConnected) {
      print('⚠️ Already connected, skipping...');
      return;
    }

    print('🚀 Starting connection process...');
    state = state.copyWith(
      isConnecting: true,
      error: null,
      connectionState: WebSocketConnectionState.connecting,
    );

    try {
      await _connectToChatUseCase(token);
      print('✅ Connect to chat call completed');

      // Note: Don't update state here - let the connection stream handle it
      // This prevents race conditions
    } catch (e) {
      print('❌ Connection failed: $e');
      state = state.copyWith(
        isConnecting: false,
        connectionState: WebSocketConnectionState.error,
        error: 'Failed to connect to chat: $e',
      );
    }
  }

  Future<void> connectToNotification(String? token) async {
    try {
      await _connectToNotificationUseCase(token);
      print('✅ Connect to notification call completed');
    } catch (e) {
      print('❌ Notification connection failed: $e');
      state = state.copyWith(error: 'Failed to connect to notifications: $e');
    }
  }

  void disconnect() {
    print('🔌 Disconnecting WebSocket...');
    _disconnectUseCase();
    state = state.copyWith(
      messages: [],
      notifications: [],
      currentRoomID: null,
    );
  }

  void joinRoom({required int interestID}) {
    if (!state.isConnected) {
      print('❌ Cannot join room: not connected');
      state = state.copyWith(error: 'Not connected to WebSocket');
      return;
    }

    print('🚪 Joining room: $interestID');
    _joinRoomUseCase(interestID: interestID);
  }

  void leftRoom({required int interestID}) {
    if (!state.isConnected) {
      print('❌ Cannot leave room: not connected');
      return;
    }

    print('🚪 Leaving room: $interestID');
    _leftRoomUseCase(interestID: interestID);
  }

  void sendMessage({
    required int interestID,
    required bool isOwner,
    required int userID,
    required String message,
  }) {
    if (!state.isConnected) {
      print('❌ Cannot send message: not connected');
      state = state.copyWith(error: 'Not connected to WebSocket');
      return;
    }

    if (message.trim().isEmpty) {
      print('❌ Cannot send empty message');
      state = state.copyWith(error: 'Message cannot be empty');
      return;
    }

    print('📤 Sending message: $message');
    _sendMessageUseCase(
      interestID: interestID,
      isOwner: isOwner,
      userID: userID,
      message: message,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  void clearNotifications() {
    state = state.copyWith(notifications: []);
  }

  @override
  void dispose() {
    print('🗑️ Disposing WebSocket notifier...');
    _connectionSubscription?.cancel();
    _responseSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}
