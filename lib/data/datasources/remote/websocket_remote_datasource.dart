import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/websocket_event.dart';

abstract class WebSocketRemoteDataSource {
  Stream<WebSocketResponse> get responseStream;
  Stream<WebSocketConnectionState> get connectionStream;
  WebSocketConnectionState get currentConnectionState;

  Future<void> connect(String? token);
  void disconnect();
  void sendEvent(WebSocketEvent event);
  void dispose();
}

class WebSocketRemoteDataSourceImpl implements WebSocketRemoteDataSource {
  final WebSocketClient _client;

  WebSocketRemoteDataSourceImpl(this._client);

  @override
  Stream<WebSocketResponse> get responseStream =>
      _client.messageStream.map((data) => WebSocketResponse.fromJson(data));

  @override
  Stream<WebSocketConnectionState> get connectionStream =>
      _client.connectionStream;

  @override
  WebSocketConnectionState get currentConnectionState => _client.currentState;

  @override
  Future<void> connect(String? token) async {
    await _client.connect(token);
  }

  @override
  void disconnect() {
    _client.disconnect();
  }

  @override
  void sendEvent(WebSocketEvent event) {
    _client.sendEvent(event.event.value, event.data);
  }

  @override
  void dispose() {
    _client.dispose();
  }
}
