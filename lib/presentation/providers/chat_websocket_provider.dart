import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/message_socket.dart';
import 'package:trao_doi_do_app/domain/entities/chat_notification.dart';
import 'package:trao_doi_do_app/domain/repositories/multi_websocket_repository.dart';

class ChatWebSocketState {
  final WebSocketConnectionState connectionState;
  final List<MessageSocket> messages;
  final WebSocketResponse? lastResponse;
  final String? error;
  final bool isConnecting;
  final String? currentRoomID;

  const ChatWebSocketState({
    this.connectionState = WebSocketConnectionState.disconnected,
    this.messages = const [],
    this.lastResponse,
    this.error,
    this.isConnecting = false,
    this.currentRoomID,
  });

  ChatWebSocketState copyWith({
    WebSocketConnectionState? connectionState,
    List<MessageSocket>? messages,
    List<ChatNotification>? notifications,
    WebSocketResponse? lastResponse,
    String? error,
    bool? isConnecting,
    String? currentRoomID,
  }) {
    return ChatWebSocketState(
      connectionState: connectionState ?? this.connectionState,
      messages: messages ?? this.messages,
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

class ChatWebSocketNotifier extends StateNotifier<ChatWebSocketState> {
  final MultiWebSocketRepository _repository;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _responseSubscription;

  ChatWebSocketNotifier(this._repository) : super(const ChatWebSocketState()) {
    _listenToConnectionState();
    _listenToChatResponses();
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

        // Clear messages when disconnected
        if (connectionState == WebSocketConnectionState.disconnected) {
          state = state.copyWith(messages: [], currentRoomID: null);
        }
      },
      onError: (error) {
        print('❌ Chat connection stream error: $error');
        state = state.copyWith(
          connectionState: WebSocketConnectionState.error,
          error: 'Connection stream error: $error',
          isConnecting: false,
        );
      },
    );
  }

  void _listenToChatResponses() {
    _responseSubscription = _repository.chatResponseStream.listen(
      (response) {
        state = state.copyWith(lastResponse: response);

        switch (response.event) {
          case 'join_room_response':
            if (response.isSuccess && response.data != null) {
              final roomID = response.data!['roomID'] as String?;
              state = state.copyWith(currentRoomID: roomID);
            } else {
              state = state.copyWith(
                error: response.error ?? 'Failed to join chat room',
              );
            }
            break;

          case 'send_message_response':
            if (response.isSuccess && response.data != null) {
              _handleNewChatMessage(response.data!);
            } else {
              state = state.copyWith(
                error: response.error ?? 'Failed to send chat message',
              );
            }
            break;

          case 'send_transaction_response':
            // Xử lý response từ transaction
            if (response.isSuccess) {
              // Transaction thành công - UI sẽ handle refresh
            } else {
              state = state.copyWith(
                error: response.error ?? 'Failed to send transaction',
              );
            }
            break;

          case 'left_room_response':
            if (response.isSuccess) {
              state = state.copyWith(messages: [], currentRoomID: null);
            }
            break;

          case 'pong':
            break;

          default:
        }
      },
      onError: (error) {
        state = state.copyWith(error: 'Response stream error: $error');
      },
    );
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
      return;
    }

    if (state.isConnected) {
      return;
    }

    // ✅ SET CONNECTING STATE NGAY LẬP TỨC
    state = state.copyWith(
      isConnecting: true,
      error: null,
      connectionState: WebSocketConnectionState.connecting,
    );

    try {
      await _repository.connectToChat(token);

      // Connection state sẽ được cập nhật qua stream listener
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        connectionState: WebSocketConnectionState.error,
        error: 'Failed to connect to chat: $e',
      );
    }
  }

  void _handleNewChatMessage(Map<String, dynamic> data) {
    try {
      final message = MessageSocket.fromJson(data);
      final updatedMessages = [message, ...state.messages];
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: 'Error parsing chat message: $e');
    }
  }

  // ✅ THÊM METHOD ĐỂ FORCE RECONNECT
  Future<void> reconnect(String? token) async {
    // Disconnect first
    disconnect();

    // Wait a bit before reconnecting
    await Future.delayed(const Duration(milliseconds: 500));

    // Connect again
    await connect(token);
  }

  Future<void> connectToChat(String? token) async {
    return connect(token);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void disconnectChat() {
    disconnect();
  }

  void joinRoom(int interestID) {
    if (!state.isConnected) {
      return;
    }

    _repository.joinRoom(interestID: interestID);
  }

  void leftRoom(int interestID) {
    if (!state.isConnected) {
      return;
    }

    _repository.leftRoom(interestID: interestID);
  }

  void sendMessage({
    required int interestID,
    required bool isOwner,
    required int userID,
    required String message,
  }) {
    if (!state.isConnected) {
      state = state.copyWith(error: 'Cannot send message: not connected');
      return;
    }

    _repository.sendMessage(
      interestID: interestID,
      isOwner: isOwner,
      userID: userID,
      message: message,
    );
  }

  void sendTransaction({required int interestID, required int receiverID}) {
    if (!state.isConnected) {
      state = state.copyWith(error: 'Cannot send transaction: not connected');
      return;
    }

    _repository.sendTransaction(interestID: interestID, receiverID: receiverID);
  }

  void clearChatError() {
    state = state.copyWith(error: null);
  }

  void clearChatMessages() {
    state = state.copyWith(messages: []);
  }

  void disconnect() {
    _repository.disconnectChat();

    state = state.copyWith(
      connectionState: WebSocketConnectionState.disconnected,
      messages: [],
      currentRoomID: null,
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
