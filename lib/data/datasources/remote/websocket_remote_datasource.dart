import 'dart:async';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/websocket_event.dart';

abstract class WebSocketRemoteDataSource {
  Stream<WebSocketResponse> get responseStream;
  Stream<WebSocketConnectionState> get connectionStream;
  WebSocketConnectionState get currentConnectionState;

  Future<void> connectToChat(String? token);
  Future<void> connectToChatNotification(String? token);
  void disconnect();
  void sendEvent(WebSocketEvent event);
  void dispose();
}

class WebSocketRemoteDataSourceImpl implements WebSocketRemoteDataSource {
  final WebSocketClient _chatClient;
  final WebSocketClient _chatNotificationClient;
  WebSocketClient? _activeClient;

  // StreamControllers để broadcast events từ active client
  final StreamController<WebSocketResponse> _responseController =
      StreamController<WebSocketResponse>.broadcast();
  final StreamController<WebSocketConnectionState> _connectionController =
      StreamController<WebSocketConnectionState>.broadcast();

  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  StreamSubscription<WebSocketConnectionState>? _connectionSubscription;

  WebSocketRemoteDataSourceImpl(this._chatClient, this._chatNotificationClient);

  @override
  Stream<WebSocketResponse> get responseStream => _responseController.stream;

  @override
  Stream<WebSocketConnectionState> get connectionStream =>
      _connectionController.stream;

  @override
  WebSocketConnectionState get currentConnectionState {
    return _activeClient?.currentState ?? WebSocketConnectionState.disconnected;
  }

  @override
  Future<void> connectToChat(String? token) async {
    await _switchActiveClient(_chatClient);
    await _chatClient.connect(token, '/chat');
  }

  @override
  Future<void> connectToChatNotification(String? token) async {
    await _switchActiveClient(_chatNotificationClient);
    await _chatNotificationClient.connect(token, '/chat-noti');
  }

  Future<void> _switchActiveClient(WebSocketClient newClient) async {
    if (_activeClient == newClient) {
      return;
    }

    // Cancel existing subscriptions
    await _messageSubscription?.cancel();
    await _connectionSubscription?.cancel();

    // Set new active client
    _activeClient = newClient;

    // Subscribe to new client's streams
    _messageSubscription = newClient.messageStream.listen((data) {
      final response = WebSocketResponse.fromJson(data);
      _responseController.add(response);
    }, onError: (error) {});

    _connectionSubscription = newClient.connectionStream.listen((state) {
      _connectionController.add(state);
    }, onError: (error) {});
  }

  @override
  void disconnect() {
    if (_activeClient != null) {
      _activeClient!.disconnect();
      // Don't set _activeClient to null here, let it be handled by connection state
    }
  }

  @override
  void sendEvent(WebSocketEvent event) {
    if (_activeClient != null) {
      _activeClient!.sendEvent(event.event.value, event.data);
    } else {}
  }

  @override
  void dispose() {
    // Cancel subscriptions
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();

    // Close controllers
    _responseController.close();
    _connectionController.close();

    // Dispose clients
    _chatClient.dispose();
    _chatNotificationClient.dispose();

    _activeClient = null;
  }
}
