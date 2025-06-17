import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:trao_doi_do_app/core/config/flavor.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

enum WebSocketConnectionState { connecting, connected, disconnected, error }

class WebSocketClient {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketConnectionState> _connectionController =
      StreamController<WebSocketConnectionState>.broadcast();

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isManualDisconnect = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // Create a logger instance
  final LoggerUtils _logger = LoggerUtils();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<WebSocketConnectionState> get connectionStream =>
      _connectionController.stream;

  WebSocketConnectionState _currentState =
      WebSocketConnectionState.disconnected;
  WebSocketConnectionState get currentState => _currentState;

  Future<void> connect(String? token) async {
    if (_currentState == WebSocketConnectionState.connected) return;

    _isManualDisconnect = false;
    _updateConnectionState(WebSocketConnectionState.connecting);

    try {
      final wsUrl =
          token != null
              ? '${AppConfig.wsDomain}?token=$token'
              : AppConfig.wsDomain;

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      await _channel!.ready;
      _updateConnectionState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;

      _startHeartbeat();
      _listenToMessages();

      _logger.i('WebSocket connected successfully');
    } catch (e) {
      _logger.e('WebSocket connection failed: $e');
      _updateConnectionState(WebSocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  void _updateConnectionState(WebSocketConnectionState state) {
    _currentState = state;
    _connectionController.add(state);
  }

  void _listenToMessages() {
    _channel?.stream.listen(
      (data) {
        try {
          final Map<String, dynamic> message = json.decode(data);
          _messageController.add(message);
          _logger.i('WebSocket message received: $message');
        } catch (e) {
          _logger.e('Failed to parse WebSocket message: $e');
        }
      },
      onError: (error) {
        _logger.e('WebSocket stream error: $error');
        _updateConnectionState(WebSocketConnectionState.error);
        if (!_isManualDisconnect) {
          _scheduleReconnect();
        }
      },
      onDone: () {
        _logger.i('WebSocket connection closed');
        _updateConnectionState(WebSocketConnectionState.disconnected);
        _stopHeartbeat();
        if (!_isManualDisconnect) {
          _scheduleReconnect();
        }
      },
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_currentState == WebSocketConnectionState.connected) {
        sendEvent('ping', {});
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    if (_isManualDisconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      _logger.i('WebSocket reconnection attempt $_reconnectAttempts');
      connect(null); // You might need to store and pass the token
    });
  }

  void sendEvent(String event, Map<String, dynamic> data) {
    if (_currentState != WebSocketConnectionState.connected) {
      _logger.w('Cannot send message: WebSocket not connected');
      return;
    }

    try {
      final message = {'event': event, 'data': data};

      final jsonMessage = json.encode(message);
      _channel?.sink.add(jsonMessage);
      _logger.i('WebSocket message sent: $message');
    } catch (e) {
      _logger.e('Failed to send WebSocket message: $e');
    }
  }

  void disconnect() {
    _isManualDisconnect = true;
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _channel?.sink.close();
    _updateConnectionState(WebSocketConnectionState.disconnected);
    _logger.i('WebSocket manually disconnected');
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
