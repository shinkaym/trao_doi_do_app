import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';

abstract class MultiWebSocketRepository {
  // Streams
  Stream<WebSocketResponse> get responseStream;
  Stream<WebSocketConnectionState> get connectionStream;
  Stream<WebSocketResponse> get chatResponseStream;
  Stream<WebSocketResponse> get notificationResponseStream;

  // Connection management
  Future<void> connectToChat(String? token);
  Future<void> connectToNotification(String? token);
  Future<void> connectBoth(String? token);

  // State getters
  WebSocketConnectionState get chatConnectionState;
  WebSocketConnectionState get notificationConnectionState;

  // Chat actions
  void sendMessage({
    required int interestID,
    required bool isOwner,
    required int userID,
    required String message,
  });
  void joinRoom({required int interestID});
  void leftRoom({required int interestID});

  // Disconnect actions
  void disconnectChat();
  void disconnectNotification();
  void disconnectAll();
  void dispose();
}
