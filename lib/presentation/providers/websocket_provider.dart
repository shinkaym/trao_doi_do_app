import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/message_socket.dart';
import 'package:trao_doi_do_app/domain/usecases/websocket_usecases.dart';

class WebSocketState {
  final WebSocketConnectionState connectionState;
  final List<MessageSocket> messages;
  final WebSocketResponse? lastResponse;
  final String? error;
  final bool isConnecting;

  const WebSocketState({
    this.connectionState = WebSocketConnectionState.disconnected,
    this.messages = const [],
    this.lastResponse,
    this.error,
    this.isConnecting = false,
  });

  WebSocketState copyWith({
    WebSocketConnectionState? connectionState,
    List<MessageSocket>? messages,
    WebSocketResponse? lastResponse,
    String? error,
    bool? isConnecting,
  }) {
    return WebSocketState(
      connectionState: connectionState ?? this.connectionState,
      messages: messages ?? this.messages,
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

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  final ConnectWebSocketUseCase _connectUseCase;
  final DisconnectWebSocketUseCase _disconnectUseCase;
  final JoinRoomUseCase _joinRoomUseCase;
  final LeftRoomUseCase _leftRoomUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final GetWebSocketResponseStreamUseCase _getResponseStreamUseCase;
  final GetWebSocketConnectionStreamUseCase _getConnectionStreamUseCase;

  WebSocketNotifier(
    this._connectUseCase,
    this._disconnectUseCase,
    this._joinRoomUseCase,
    this._leftRoomUseCase,
    this._sendMessageUseCase,
    this._getResponseStreamUseCase,
    this._getConnectionStreamUseCase,
  ) : super(const WebSocketState()) {
    _listenToConnectionStream();
    _listenToResponseStream();
  }

  void _listenToConnectionStream() {
    _getConnectionStreamUseCase().listen((connectionState) {
      state = state.copyWith(
        connectionState: connectionState,
        isConnecting: connectionState == WebSocketConnectionState.connecting,
        error:
            connectionState == WebSocketConnectionState.error
                ? 'Connection failed'
                : null,
      );
    });
  }

  void _listenToResponseStream() {
    _getResponseStreamUseCase().listen((response) {
      state = state.copyWith(lastResponse: response);
      _handleWebSocketResponse(response);
    });
  }

  void _handleWebSocketResponse(WebSocketResponse response) {
    switch (response.event) {
      case 'send_message':
        if (response.isSuccess && response.data != null) {
          _handleNewMessage(response.data!);
        }
        break;
      case 'join_room':
        if (response.isSuccess) {
          // Handle successful room join
          print('Successfully joined room');
        } else {
          state = state.copyWith(
            error: response.error ?? 'Failed to join room',
          );
        }
        break;
      case 'left_room':
        if (response.isSuccess) {
          // Handle successful room leave
          print('Successfully left room');
          state = state.copyWith(
            messages: [],
          ); // Clear messages when leaving room
        }
        break;
      case 'pong':
        // Handle heartbeat response
        break;
      default:
        print('Unhandled WebSocket event: ${response.event}');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final message = MessageSocket(
        id: data['id'] as int?,
        senderID: data['senderID'] as int,
        roomID: data['roomID'] as String,
        message: data['message'] as String,
        timestamp: DateTime.parse(data['timestamp'] as String),
        isOwner: data['isOwner'] as bool,
      );

      final updatedMessages = [...state.messages, message];
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  Future<void> connect(String? token) async {
    if (state.isConnecting || state.isConnected) return;

    state = state.copyWith(isConnecting: true, error: null);

    try {
      await _connectUseCase(token);
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: 'Failed to connect: $e',
      );
    }
  }

  void disconnect() {
    _disconnectUseCase();
    state = state.copyWith(messages: []); // Clear messages on disconnect
  }

  void joinRoom({required bool isOwner, required int userID}) {
    if (!state.isConnected) {
      state = state.copyWith(error: 'Not connected to WebSocket');
      return;
    }

    _joinRoomUseCase(isOwner: isOwner, userID: userID);
  }

  void leftRoom({required bool isOwner, required int userID}) {
    if (!state.isConnected) return;

    _leftRoomUseCase(isOwner: isOwner, userID: userID);
  }

  void sendMessage({
    required bool isOwner,
    required int userID,
    required String message,
  }) {
    if (!state.isConnected) {
      state = state.copyWith(error: 'Not connected to WebSocket');
      return;
    }

    if (message.trim().isEmpty) {
      state = state.copyWith(error: 'Message cannot be empty');
      return;
    }

    _sendMessageUseCase(isOwner: isOwner, userID: userID, message: message);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
