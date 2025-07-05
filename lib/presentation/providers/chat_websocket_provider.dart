import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/multi_websocket_manager.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/message_socket.dart';
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
    _syncConnectionState();
  }

  Stream<WebSocketResponse> get chatResponseStream =>
      _repository.chatResponseStream;
  
  void _syncConnectionState() {
    final connectionState = _repository.chatConnectionState;
    state = state.copyWith(
      connectionState: connectionState,
      isConnecting: connectionState == WebSocketConnectionState.connecting,
      error: connectionState == WebSocketConnectionState.error
          ? 'Chat connection error'
          : null,
    );
  }

  void _listenToConnectionState() {
    _connectionSubscription = _repository.connectionStream.listen(
      (states) {
        // Lấy trạng thái của channel chat từ Map
        final connectionState = states[WebSocketChannel.chat] ??
            WebSocketConnectionState.disconnected;
        state = state.copyWith(
          connectionState: connectionState,
          isConnecting: connectionState == WebSocketConnectionState.connecting,
          error: connectionState == WebSocketConnectionState.error
              ? 'Chat connection error'
              : null,
        );

        if (connectionState == WebSocketConnectionState.disconnected) {
          state = state.copyWith(messages: [], currentRoomID: null);
        }
      },
      onError: (error) {
        state = state.copyWith(
          connectionState: WebSocketConnectionState.error,
          error: 'Chat connection stream error: $error',
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
            if (response.isSuccess) {
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
        }
      },
      onError: (error) {
        state = state.copyWith(error: 'Chat response stream error: $error');
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

    if (state.isConnecting || state.isConnected) {
      return;
    }

    state = state.copyWith(
      isConnecting: true,
      error: null,
      connectionState: WebSocketConnectionState.connecting,
    );

    try {
      await _repository.connectToChat(token);
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

  Future<void> reconnect(String? token) async {
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect(token);
  }

  void joinRoom(int interestID) {
    if (!state.isConnected) {
      state = state.copyWith(error: 'Cannot join room: not connected');
      return;
    }

    _repository.joinRoom(interestID: interestID);
  }

  void leftRoom(int interestID) {
    if (!state.isConnected) {
      state = state.copyWith(error: 'Cannot leave room: not connected');
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

  void clearError() {
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