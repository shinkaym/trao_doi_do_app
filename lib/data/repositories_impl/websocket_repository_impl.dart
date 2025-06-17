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
  Future<void> connect(String? token) async {
    await _remoteDataSource.connect(token);
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
  void joinRoom({required bool isOwner, required int userID}) {
    final event = WebSocketEvent.joinRoom(isOwner: isOwner, userID: userID);
    sendEvent(event);
  }

  @override
  void leftRoom({required bool isOwner, required int userID}) {
    final event = WebSocketEvent.leftRoom(isOwner: isOwner, userID: userID);
    sendEvent(event);
  }

  @override
  void sendMessage({
    required bool isOwner,
    required int userID,
    required String message,
  }) {
    final event = WebSocketEvent.sendMessage(
      isOwner: isOwner,
      userID: userID,
      message: message,
    );
    sendEvent(event);
  }

  @override
  void dispose() {
    _remoteDataSource.dispose();
  }
}
