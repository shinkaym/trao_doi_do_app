import 'dart:async';
import 'package:trao_doi_do_app/core/network/multi_websocket_manager.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/websocket_event.dart';

abstract class MultiWebSocketRemoteDataSource {
  // General streams
  Stream<WebSocketResponse> get responseStream;
  Stream<WebSocketConnectionState> get connectionStream;

  // Specific streams
  Stream<WebSocketResponse> get chatResponseStream;
  Stream<WebSocketResponse> get chatNotificationResponseStream;
  Stream<WebSocketResponse> get notificationResponseStream;

  // Connection methods
  Future<void> connectToChat(String? token);
  Future<void> connectToChatNotification(String? token);
  Future<void> connectToNotification(String? token);
  Future<void> connectAll(String? token);

  // State getters
  WebSocketConnectionState get chatConnectionState;
  WebSocketConnectionState get chatNotificationConnectionState;
  WebSocketConnectionState get notificationConnectionState;

  // Actions
  void sendChatEvent(WebSocketEvent event);
  void sendChatNotificationEvent(WebSocketEvent event);
  void sendNotificationEvent(WebSocketEvent event);
  void disconnectChat();
  void disconnectChatNotification();
  void disconnectNotification();
  void disconnectAll();
  void dispose();
}

class MultiWebSocketRemoteDataSourceImpl
    implements MultiWebSocketRemoteDataSource {
  final MultiWebSocketManager _manager;

  MultiWebSocketRemoteDataSourceImpl(this._manager);

  @override
  Stream<WebSocketResponse> get responseStream => _manager.responseStream;

  @override
  Stream<WebSocketConnectionState> get connectionStream =>
      _manager.connectionStream;

  @override
  Stream<WebSocketResponse> get chatResponseStream =>
      _manager.chatResponseStream;

  @override
  Stream<WebSocketResponse> get chatNotificationResponseStream =>
      _manager.chatNotificationResponseStream;

  @override
  Stream<WebSocketResponse> get notificationResponseStream =>
      _manager.notificationResponseStream;

  @override
  Future<void> connectToChat(String? token) => _manager.connectToChat(token);

  @override
  Future<void> connectToNotification(String? token) =>
      _manager.connectToNotification(token);

  @override
  Future<void> connectAll(String? token) async {
    await Future.wait([
      _manager.connectToChat(token),
      _manager.connectToChatNotification(token),
      _manager.connectToNotification(token),
    ]);
  }

  @override
  Future<void> connectToChatNotification(String? token) =>
      _manager.connectToChatNotification(token);

  @override
  WebSocketConnectionState get chatConnectionState =>
      _manager.getChatConnectionState();

  @override
  WebSocketConnectionState get chatNotificationConnectionState =>
      _manager.getChatNotificationConnectionState();

  @override
  WebSocketConnectionState get notificationConnectionState =>
      _manager.getNotificationConnectionState();

  @override
  void sendChatEvent(WebSocketEvent event) {
    _manager.sendChatEvent(event.event.value, event.data);
  }

  @override
  void sendChatNotificationEvent(WebSocketEvent event) {
    _manager.sendChatNotificationEvent(event.event.value, event.data);
  }

  @override
  void sendNotificationEvent(WebSocketEvent event) {
    _manager.sendNotificationEvent(event.event.value, event.data);
  }

  @override
  void disconnectChat() => _manager.disconnectChat();

  @override
  void disconnectChatNotification() => _manager.disconnectChatNotification();

  @override
  void disconnectNotification() => _manager.disconnectNotification();

  @override
  void disconnectAll() => _manager.disconnectAll();

  @override
  void dispose() => _manager.dispose();
}
