import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WebSocketConnectionState {
  connecting,
  connected,
  disconnected,
  error,
}

class WebSocketClient {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketConnectionState> _stateController =
      StreamController<WebSocketConnectionState>.broadcast();
  WebSocketConnectionState _currentState = WebSocketConnectionState.disconnected;
  Timer? _pingTimer;
  static const Duration _pingInterval = Duration(seconds: 30);
  static const Duration _timeoutDuration = Duration(seconds: 60);
  Timer? _timeoutTimer;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<WebSocketConnectionState> get connectionStream => _stateController.stream;
  WebSocketConnectionState get currentState => _currentState;

  Future<void> connect(String? token, String endpoint) async {
    if (_currentState == WebSocketConnectionState.connected) return;

    _updateState(WebSocketConnectionState.connecting);
    try {
      final wsUrl = 'ws://34.142.168.171:8001$endpoint';
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: token != null ? [token] : null,
      );

      await _channel!.ready;
      _updateState(WebSocketConnectionState.connected);

      // Start ping timer
      _startPingTimer();

      _channel!.stream.listen(
        (data) => _handleIncomingData(data),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );
    } catch (e) {
      _updateState(WebSocketConnectionState.error);
      _messageController.addError('Failed to connect: $e');
      _reconnect();
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel(); // Cancel any existing ping timer
    _timeoutTimer?.cancel(); // Cancel any existing timeout timer

    // Send ping every 30 seconds
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      sendEvent('ping', {});
      // Start or reset timeout timer
      _resetTimeoutTimer();
    });
  }

  void _resetTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_timeoutDuration, () {
      _updateState(WebSocketConnectionState.disconnected);
      _reconnect();
    });
  }

  void _handleIncomingData(dynamic data) {
    try {
      final message = json.decode(data.toString());
      if (message['event'] == 'keep_alive') {
        _updateState(WebSocketConnectionState.connected);
        _resetTimeoutTimer(); // Reset timeout on receiving keep_alive
      } else {
        _messageController.add(message);
      }
    } catch (e) {
      print('Error parsing WebSocket data: $e');
      _updateState(WebSocketConnectionState.error);
      _messageController.addError('Error parsing message: $e');
    }
  }

  void _handleError(dynamic error) {
    _updateState(WebSocketConnectionState.error);
    _stateController.addError('WebSocket error: $error');
    _reconnect();
  }

  void _handleDisconnect() {
    _updateState(WebSocketConnectionState.disconnected);
    _pingTimer?.cancel();
    _timeoutTimer?.cancel();
    _reconnect();
  }

  void _updateState(WebSocketConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }

  Future<void> _reconnect() async {
    _pingTimer?.cancel();
    _timeoutTimer?.cancel();
    await Future.delayed(Duration(seconds: 5)); // Simple delay before reconnect
    await connect(null, ''); // Token and endpoint will be provided by the manager
  }

  void sendEvent(String event, Map<String, dynamic> data) {
    if (_currentState != WebSocketConnectionState.connected) {
      _messageController.addError('Cannot send event: not connected');
      return;
    }

    try {
      final message = json.encode({
        'event': event,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _channel!.sink.add(message);
    } catch (e) {
      _messageController.addError('Error sending event: $e');
    }
  }

  void disconnect() {
    _pingTimer?.cancel();
    _timeoutTimer?.cancel();
    _channel?.sink.close();
    _updateState(WebSocketConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _stateController.close();
  }
}