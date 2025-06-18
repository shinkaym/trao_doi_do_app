import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/websocket_event.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';

abstract class WebSocketRepository {
  Stream<WebSocketResponse> get responseStream;
  Stream<WebSocketConnectionState> get connectionStream;
  WebSocketConnectionState get currentConnectionState;

  Future<void> connectToChat(String? token);
  Future<void> connectToNotification(String? token);
  void disconnect();
  void sendEvent(WebSocketEvent event);
  void joinRoom({required int interestID});
  void leftRoom({required int interestID});
  void sendMessage({
    required int interestID,
    required bool isOwner,
    required int userID,
    required String message,
  });
  void dispose();
}
