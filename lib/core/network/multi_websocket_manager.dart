import 'dart:async';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';

enum WebSocketChannel { chat, chatNotification }

class MultiWebSocketManager {
  final Map<WebSocketChannel, WebSocketClient> _clients = {};
  final StreamController<WebSocketResponse> _responseController =
      StreamController<WebSocketResponse>.broadcast();
  final StreamController<WebSocketConnectionState> _connectionController =
      StreamController<WebSocketConnectionState>.broadcast();

  final Map<WebSocketChannel, StreamSubscription> _messageSubscriptions = {};
  final Map<WebSocketChannel, StreamSubscription> _connectionSubscriptions = {};

  Stream<WebSocketResponse> get responseStream => _responseController.stream;
  Stream<WebSocketConnectionState> get connectionStream =>
      _connectionController.stream;

  // ✅ Updated filtered streams với channel source
  Stream<WebSocketResponse> get chatResponseStream => responseStream
      .where((response) => response.sourceChannel == 'chat');

  Stream<WebSocketResponse> get chatNotificationResponseStream => responseStream
      .where((response) => response.sourceChannel == 'chat-noti');

  MultiWebSocketManager() {
    _clients[WebSocketChannel.chat] = WebSocketClient();
    _clients[WebSocketChannel.chatNotification] = WebSocketClient();
  }

  Future<void> connectToChat(String? token) async {
    await _connectChannel(WebSocketChannel.chat, token, '/chat');
  }

  Future<void> connectToChatNotification(String? token) async {
    await _connectChannel(
      WebSocketChannel.chatNotification,
      token,
      '/chat-noti',
    );
  }

  Future<void> _connectChannel(
    WebSocketChannel channel,
    String? token,
    String endpoint,
  ) async {
    final client = _clients[channel]!;

    // Setup subscriptions before connecting
    _setupChannelSubscriptions(channel);

    await client.connect(token, endpoint);
  }

  void _setupChannelSubscriptions(WebSocketChannel channel) {
    final client = _clients[channel]!;

    // Cancel existing subscriptions
    _messageSubscriptions[channel]?.cancel();
    _connectionSubscriptions[channel]?.cancel();

    // ✅ Message subscription với channel tagging
    _messageSubscriptions[channel] = client.messageStream.listen((data) {
      final response = WebSocketResponse.fromJson(data);
      
      // ✅ Tag response với source channel
      final taggedResponse = response.copyWithSourceChannel(
        sourceChannel: channel == WebSocketChannel.chat ? 'chat' : 'chat-noti'
      );
      
      _responseController.add(taggedResponse);
    }, onError: (error) => {});

    // Connection subscription
    _connectionSubscriptions[channel] = client.connectionStream.listen((state) {
      _connectionController.add(state);
    }, onError: (error) => {});
  }

  void sendChatEvent(String event, Map<String, dynamic> data) {
    _clients[WebSocketChannel.chat]?.sendEvent(event, data);
  }

  void sendChatNotificationEvent(String event, Map<String, dynamic> data) {
    _clients[WebSocketChannel.chatNotification]?.sendEvent(event, data);
  }

  WebSocketConnectionState getChatConnectionState() {
    return _clients[WebSocketChannel.chat]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  WebSocketConnectionState getChatNotificationConnectionState() {
    return _clients[WebSocketChannel.chatNotification]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  void disconnectChat() {
    _clients[WebSocketChannel.chat]?.disconnect();
  }

  void disconnectChatNotification() {
    _clients[WebSocketChannel.chatNotification]?.disconnect();
  }

  void disconnectAll() {
    _clients.values.forEach((client) => client.disconnect());
  }

  void dispose() {
    _messageSubscriptions.values.forEach((sub) => sub.cancel());
    _connectionSubscriptions.values.forEach((sub) => sub.cancel());
    _clients.values.forEach((client) => client.dispose());
    _responseController.close();
    _connectionController.close();
  }
}