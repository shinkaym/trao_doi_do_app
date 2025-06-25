import 'package:trao_doi_do_app/data/datasources/remote/websocket_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/repositories/websocket_repository.dart';
import 'package:trao_doi_do_app/domain/entities/websocket_event.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';

class WebSocketRepositoryImpl implements WebSocketRepository {
  final WebSocketRemoteDataSource _remoteDataSource;

  WebSocketRepositoryImpl(this._remoteDataSource);

  @override
  Stream<WebSocketResponse> get responseStream =>
      _remoteDataSource.responseStream;

  @override
  Stream<WebSocketConnectionState> get connectionStream =>
      _remoteDataSource.connectionStream;

  @override
  WebSocketConnectionState get currentConnectionState =>
      _remoteDataSource.currentConnectionState;

  @override
  Future<void> connectToChat(String? token) async {
    await _remoteDataSource.connectToChat(token);
  }

  @override
  Future<void> connectToChatNotification(String? token) async {
    await _remoteDataSource.connectToChatNotification(token);
  }

  @override
  void disconnect() {
    _remoteDataSource.disconnect();
  }

  @override
  void sendEvent(WebSocketEvent event) {
    _remoteDataSource.sendEvent(event);
  }

  @override
  void joinRoom({required int interestID}) {
    final event = WebSocketEvent.joinRoom(interestID: interestID);
    sendEvent(event);
  }

  @override
  void leftRoom({required int interestID}) {
    final event = WebSocketEvent.leftRoom(interestID: interestID);
    sendEvent(event);
  }

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
    sendEvent(event);
  }

  @override
  void sendTransaction({required int interestID, required int receiverID}) {
    final event = WebSocketEvent.sendTransaction(
      interestID: interestID,
      receiverID: receiverID,
    );
    sendEvent(event);
  }

  @override
  void dispose() {
    _remoteDataSource.dispose();
  }
}
