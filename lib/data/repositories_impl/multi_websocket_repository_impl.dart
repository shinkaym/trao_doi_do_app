import 'package:trao_doi_do_app/data/datasources/remote/multi_websocket_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/repositories/multi_websocket_repository.dart';
import 'package:trao_doi_do_app/domain/entities/websocket_event.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';

class MultiWebSocketRepositoryImpl implements MultiWebSocketRepository {
  final MultiWebSocketRemoteDataSource _remoteDataSource;

  MultiWebSocketRepositoryImpl(this._remoteDataSource);

  @override
  Stream<WebSocketResponse> get responseStream =>
      _remoteDataSource.responseStream;

  @override
  Stream<WebSocketConnectionState> get connectionStream =>
      _remoteDataSource.connectionStream;

  @override
  Stream<WebSocketResponse> get chatResponseStream =>
      _remoteDataSource.chatResponseStream;

  @override
  Stream<WebSocketResponse> get chatNotificationResponseStream =>
      _remoteDataSource.chatNotificationResponseStream;

  @override
  Stream<WebSocketResponse> get notificationResponseStream =>
      _remoteDataSource.notificationResponseStream;

  @override
  Future<void> connectToChat(String? token) =>
      _remoteDataSource.connectToChat(token);

  @override
  Future<void> connectToChatNotification(String? token) =>
      _remoteDataSource.connectToChatNotification(token);

  @override
  Future<void> connectToNotification(String? token) =>
      _remoteDataSource.connectToNotification(token);

  @override
  Future<void> connectAll(String? token) => _remoteDataSource.connectAll(token);

  @override
  WebSocketConnectionState get chatConnectionState =>
      _remoteDataSource.chatConnectionState;

  @override
  WebSocketConnectionState get chatNotificationConnectionState =>
      _remoteDataSource.chatNotificationConnectionState;

  @override
  WebSocketConnectionState get notificationConnectionState =>
      _remoteDataSource.notificationConnectionState;

  @override
  void sendMessage({
    required int interestID,
    required bool isOwner,
    required int userID,
    required String message,
  }) {
    final event = WebSocketEvent.sendMessage(
      interestID: interestID,
      isOwner: isOwner,
      userID: userID,
      message: message,
    );
    _remoteDataSource.sendChatEvent(event);
  }

  @override
  void sendTransaction({required int interestID, required int receiverID}) {
    final event = WebSocketEvent.sendTransaction(
      interestID: interestID,
      receiverID: receiverID,
    );
    _remoteDataSource.sendChatEvent(event);
  }

  @override
  void joinRoom({required int interestID}) {
    final event = WebSocketEvent.joinRoom(interestID: interestID);
    _remoteDataSource.sendChatEvent(event);
  }

  @override
  void leftRoom({required int interestID}) {
    final event = WebSocketEvent.leftRoom(interestID: interestID);
    _remoteDataSource.sendChatEvent(event);
  }

  @override
  void sendNotificationEvent(String event, Map<String, dynamic> data) {
    final wsEvent = WebSocketEvent(
      event: WebSocketEventType.fromString(event) ?? WebSocketEventType.ping,
      data: data,
    );
    _remoteDataSource.sendNotificationEvent(wsEvent);
  }

  @override
  void disconnectChat() => _remoteDataSource.disconnectChat();

  @override
  void disconnectChatNotification() =>
      _remoteDataSource.disconnectChatNotification();

  @override
  void disconnectNotification() => _remoteDataSource.disconnectNotification();

  @override
  void disconnectAll() => _remoteDataSource.disconnectAll();

  @override
  void dispose() => _remoteDataSource.dispose();
}
