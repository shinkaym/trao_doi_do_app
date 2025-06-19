import 'dart:async';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';

enum WebSocketChannel { chat, notification }

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

  // Filtered streams cho từng channel
  Stream<WebSocketResponse> get chatResponseStream =>
      responseStream.where((response) => _isChatEvent(response.event));

  Stream<WebSocketResponse> get notificationResponseStream =>
      responseStream.where((response) => _isNotificationEvent(response.event));

  MultiWebSocketManager() {
    _clients[WebSocketChannel.chat] = WebSocketClient();
    _clients[WebSocketChannel.notification] = WebSocketClient();
  }

  Future<void> connectToChat(String? token) async {
    await _connectChannel(WebSocketChannel.chat, token, '/chat');
  }

  Future<void> connectToNotification(String? token) async {
    await _connectChannel(WebSocketChannel.notification, token, '/chat-noti');
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

    // Message subscription
    _messageSubscriptions[channel] = client.messageStream.listen((data) {
      final response = WebSocketResponse.fromJson(data);
      _responseController.add(response);
    }, onError: (error) => print('❌ ${channel.name} message error: $error'));

    // Connection subscription
    _connectionSubscriptions[channel] = client.connectionStream.listen((state) {
      _connectionController.add(state);
    }, onError: (error) => print('❌ ${channel.name} connection error: $error'));
  }

  void sendChatEvent(String event, Map<String, dynamic> data) {
    _clients[WebSocketChannel.chat]?.sendEvent(event, data);
  }

  void sendNotificationEvent(String event, Map<String, dynamic> data) {
    _clients[WebSocketChannel.notification]?.sendEvent(event, data);
  }

  WebSocketConnectionState getChatConnectionState() {
    return _clients[WebSocketChannel.chat]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  WebSocketConnectionState getNotificationConnectionState() {
    return _clients[WebSocketChannel.notification]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  void disconnectChat() {
    _clients[WebSocketChannel.chat]?.disconnect();
  }

  void disconnectNotification() {
    _clients[WebSocketChannel.notification]?.disconnect();
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

  bool _isChatEvent(String event) {
    const chatEvents = [
      'send_message',
      'join_room',
      'left_room',
      'send_message_response',
      'join_room_response',
      'left_room_response',
    ];
    return chatEvents.contains(event);
  }

  bool _isNotificationEvent(String event) {
    const notificationEvents = [
      'new_notification',
      'message_notification',
      'system_notification',
    ];
    return notificationEvents.contains(event);
  }
}
