import 'dart:async';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';

enum WebSocketChannel { chat, chatNotification, notification }

class MultiWebSocketManager {
  final Map<WebSocketChannel, WebSocketClient> _clients = {};
  final StreamController<WebSocketResponse> _responseController =
      StreamController<WebSocketResponse>.broadcast();
  final StreamController<Map<WebSocketChannel, WebSocketConnectionState>>
  _connectionController =
      StreamController<
        Map<WebSocketChannel, WebSocketConnectionState>
      >.broadcast();

  final Map<WebSocketChannel, StreamSubscription> _messageSubscriptions = {};
  final Map<WebSocketChannel, StreamSubscription> _connectionSubscriptions = {};

  Stream<WebSocketResponse> get responseStream => _responseController.stream;
  Stream<Map<WebSocketChannel, WebSocketConnectionState>>
  get connectionStream => _connectionController.stream;

  Stream<WebSocketResponse> get chatResponseStream =>
      responseStream.where((response) => response.sourceChannel == 'chat');

  Stream<WebSocketResponse> get chatNotificationResponseStream =>
      responseStream.where((response) => response.sourceChannel == 'chat-noti');

  Stream<WebSocketResponse> get notificationResponseStream =>
      responseStream.where((response) => response.sourceChannel == 'noti');

  MultiWebSocketManager() {
    _clients[WebSocketChannel.chat] = WebSocketClient();
    _clients[WebSocketChannel.chatNotification] = WebSocketClient();
    _clients[WebSocketChannel.notification] = WebSocketClient();
    _updateConnectionStates();
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

  Future<void> connectToNotification(String? token) async {
    await _connectChannel(WebSocketChannel.notification, token, '/noti');
  }

  Future<void> connectAll(String? token) async {
    try {
      await Future.wait([
        connectToChat(token),
        connectToChatNotification(token),
        connectToNotification(token),
      ], eagerError: true);
    } catch (e) {
      _responseController.addError(
        'Failed to connect all channelsFailed to connect all channelsFailed to connect all channelsFailed to connect all channelsFailed to connect all channelsFailed to connect all channelsFailed to connect all channels: $e',
      );
    }
  }

  Future<void> _connectChannel(
    WebSocketChannel channel,
    String? token,
    String endpoint,
  ) async {
    final client = _clients[channel]!;
    _setupChannelSubscriptions(channel);
    try {
      await client.connect(token, endpoint);
    } catch (e) {
      _responseController.addError('Failed to connect $channel: $e');
      rethrow;
    }
  }

  void _setupChannelSubscriptions(WebSocketChannel channel) {
    final client = _clients[channel]!;

    _messageSubscriptions[channel]?.cancel();
    _connectionSubscriptions[channel]?.cancel();

    _messageSubscriptions[channel] = client.messageStream.listen(
      (data) {
        final response = WebSocketResponse.fromJson(data);
        String sourceChannel;
        switch (channel) {
          case WebSocketChannel.chat:
            sourceChannel = 'chat';
            break;
          case WebSocketChannel.chatNotification:
            sourceChannel = 'chat-noti';
            break;
          case WebSocketChannel.notification:
            sourceChannel = 'noti';
            break;
        }
        final taggedResponse = response.copyWithSourceChannel(
          sourceChannel: sourceChannel,
        );
        _responseController.add(taggedResponse);
      },
      onError: (error) {
        _responseController.addError('Message error on $channel: $error');
      },
    );

    _connectionSubscriptions[channel] = client.connectionStream.listen(
      (state) {
        _updateConnectionStates();
      },
      onError: (error) {
        _responseController.addError('Connection error on $channel: $error');
      },
    );
  }

  void _updateConnectionStates() {
    final states = {
      for (var channel in _clients.keys)
        channel: _clients[channel]!.currentState,
    };
    _connectionController.add(states);
  }

  void sendChatEvent(String event, Map<String, dynamic> data) {
    _clients[WebSocketChannel.chat]?.sendEvent(event, data);
  }

  void sendChatNotificationEvent(String event, Map<String, dynamic> data) {
    _clients[WebSocketChannel.chatNotification]?.sendEvent(event, data);
  }

  void sendNotificationEvent(String event, Map<String, dynamic> data) {
    _clients[WebSocketChannel.notification]?.sendEvent(event, data);
  }

  WebSocketConnectionState getChatConnectionState() {
    return _clients[WebSocketChannel.chat]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  WebSocketConnectionState getChatNotificationConnectionState() {
    return _clients[WebSocketChannel.chatNotification]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  WebSocketConnectionState getNotificationConnectionState() {
    return _clients[WebSocketChannel.notification]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  void disconnectChat() {
    _clients[WebSocketChannel.chat]?.disconnect();
    _updateConnectionStates();
  }

  void disconnectChatNotification() {
    _clients[WebSocketChannel.chatNotification]?.disconnect();
    _updateConnectionStates();
  }

  void disconnectNotification() {
    _clients[WebSocketChannel.notification]?.disconnect();
    _updateConnectionStates();
  }

  void disconnectAll() {
    _clients.values.forEach((client) => client.disconnect());
    _updateConnectionStates();
  }

  void dispose() {
    _messageSubscriptions.values.forEach((sub) => sub.cancel());
    _connectionSubscriptions.values.forEach((sub) => sub.cancel());
    _clients.values.forEach((client) => client.dispose());
    _responseController.close();
    _connectionController.close();
  }
}
