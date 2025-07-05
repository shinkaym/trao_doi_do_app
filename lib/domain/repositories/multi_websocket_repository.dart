import 'package:trao_doi_do_app/core/network/multi_websocket_manager.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';

abstract class MultiWebSocketRepository {
  // Streams
  Stream<WebSocketResponse> get responseStream;
  Stream<Map<WebSocketChannel, WebSocketConnectionState>> get connectionStream;
  Stream<WebSocketResponse> get chatResponseStream;
  Stream<WebSocketResponse> get chatNotificationResponseStream;
  Stream<WebSocketResponse> get notificationResponseStream;

  // Connection management
  Future<void> connectToChat(String? token);
  Future<void> connectToChatNotification(String? token);
  Future<void> connectToNotification(String? token);
  Future<void> connectAll(String? token);

  // State getters
  WebSocketConnectionState get chatConnectionState;
  WebSocketConnectionState get chatNotificationConnectionState;
  WebSocketConnectionState get notificationConnectionState;

  // Chat actions
  void sendMessage({
    required int interestID,
    required bool isOwner,
    required int userID,
    required String message,
  });
  void sendTransaction({required int interestID, required int receiverID});
  void joinRoom({required int interestID});
  void leftRoom({required int interestID});
  void sendNotificationEvent(String event, Map<String, dynamic> data);

  // Disconnect actions
  void disconnectChat();
  void disconnectChatNotification();
  void disconnectNotification();
  void disconnectAll();
  void dispose();
}