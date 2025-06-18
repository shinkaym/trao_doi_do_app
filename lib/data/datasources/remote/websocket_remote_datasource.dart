import 'dart:async';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/entities/websocket_event.dart';

abstract class WebSocketRemoteDataSource {
  Stream<WebSocketResponse> get responseStream;
  Stream<WebSocketConnectionState> get connectionStream;
  WebSocketConnectionState get currentConnectionState;

  Future<void> connectToChat(String? token);
  Future<void> connectToNotification(String? token);
  void disconnect();
  void sendEvent(WebSocketEvent event);
  void dispose();
}

class WebSocketRemoteDataSourceImpl implements WebSocketRemoteDataSource {
  final WebSocketClient _chatClient;
  final WebSocketClient _notificationClient;
  WebSocketClient? _activeClient;

  // StreamControllers để broadcast events từ active client
  final StreamController<WebSocketResponse> _responseController =
      StreamController<WebSocketResponse>.broadcast();
  final StreamController<WebSocketConnectionState> _connectionController =
      StreamController<WebSocketConnectionState>.broadcast();

  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  StreamSubscription<WebSocketConnectionState>? _connectionSubscription;

  WebSocketRemoteDataSourceImpl(this._chatClient, this._notificationClient);

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
    print('🔄 Switching to chat client...');
    await _switchActiveClient(_chatClient);
    await _chatClient.connect(token, '/chat');
  }

  @override
  Future<void> connectToNotification(String? token) async {
    print('🔄 Switching to notification client...');
    await _switchActiveClient(_notificationClient);
    await _notificationClient.connect(token, '/chat-noti');
  }

  Future<void> _switchActiveClient(WebSocketClient newClient) async {
    if (_activeClient == newClient) {
      print('✅ Already using the same client, no switch needed');
      return;
    }

    print('🔄 Switching active client...');

    // Cancel existing subscriptions
    await _messageSubscription?.cancel();
    await _connectionSubscription?.cancel();

    // Set new active client
    _activeClient = newClient;

    // Subscribe to new client's streams
    _messageSubscription = newClient.messageStream.listen(
      (data) {
        print('📨 Forwarding message from active client: ${data['event']}');
        final response = WebSocketResponse.fromJson(data);
        _responseController.add(response);
      },
      onError: (error) {
        print('❌ Message stream error: $error');
      },
    );

    _connectionSubscription = newClient.connectionStream.listen(
      (state) {
        print(
          '📡 Forwarding connection state from active client: ${state.toString()}',
        );
        _connectionController.add(state);
      },
      onError: (error) {
        print('❌ Connection stream error: $error');
      },
    );

    print('✅ Active client switched successfully');
  }

  @override
  void disconnect() {
    print('🔌 Disconnecting active client...');
    if (_activeClient != null) {
      _activeClient!.disconnect();
      // Don't set _activeClient to null here, let it be handled by connection state
    }
  }

  @override
  void sendEvent(WebSocketEvent event) {
    if (_activeClient != null) {
      print('📤 Sending event through active client: ${event.event.value}');
      _activeClient!.sendEvent(event.event.value, event.data);
    } else {
      print('❌ Cannot send event: no active client');
    }
  }

  @override
  void dispose() {
    print('🗑️ Disposing WebSocket remote data source...');

    // Cancel subscriptions
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();

    // Close controllers
    _responseController.close();
    _connectionController.close();

    // Dispose clients
    _chatClient.dispose();
    _notificationClient.dispose();

    _activeClient = null;
  }
}
