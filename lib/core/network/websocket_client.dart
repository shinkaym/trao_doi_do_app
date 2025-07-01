import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

enum WebSocketConnectionState { connecting, connected, disconnected, error }

class WebSocketClient {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketConnectionState> _connectionController =
      StreamController<WebSocketConnectionState>.broadcast();

  Timer? _reconnectTimer;
  bool _isManualDisconnect = false;
  int _reconnectAttempts = 0;
  String? _currentToken;
  String? _currentChannel;

  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  final LoggerUtils _logger = LoggerUtils();

  // Statistics tracking
  int _messagesSent = 0;
  int _messagesReceived = 0;
  DateTime? _lastMessageTime;
  DateTime? _connectionStartTime;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<WebSocketConnectionState> get connectionStream =>
      _connectionController.stream;

  WebSocketConnectionState _currentState =
      WebSocketConnectionState.disconnected;
  WebSocketConnectionState get currentState => _currentState;

  Future<void> connect(String? token, String channel) async {
    _connectionStartTime = DateTime.now();

    _logger.i('🔌 WebSocket Connection Attempt', {
      'timestamp': _connectionStartTime!.toIso8601String(),
      'channel': channel,
      'hasToken': token != null,
      'tokenLength': token?.length ?? 0,
      'currentState': _currentState.toString(),
      'previousAttempts': _reconnectAttempts,
    });

    // Check if already connected to same channel
    if (_currentState == WebSocketConnectionState.connected &&
        _currentChannel == channel) {
      _logger.w('⚠️ WebSocket already connected to same channel', {
        'channel': channel,
        'connectionDuration': _getConnectionDuration(),
        'messagesSent': _messagesSent,
        'messagesReceived': _messagesReceived,
      });
      return;
    }

    // Disconnect existing connection if any
    if (_channel != null) {
      _logger.i('🔄 Cleaning up existing connection before new connection');
      await _cleanupConnection();
    }

    _isManualDisconnect = false;
    _currentToken = token;
    _currentChannel = channel;
    _updateConnectionState(WebSocketConnectionState.connecting);

    try {
      final wsUrl = 'ws://34.142.168.171:8001$channel';

      _logger.i('🚀 Creating WebSocket connection', {
        'url': wsUrl,
        'protocols': token != null ? ['[TOKEN_PROVIDED]'] : null,
        'attemptNumber': _reconnectAttempts + 1,
      });

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: token != null ? [token] : null,
      );

      // Wait for connection to be ready with timeout
      await _channel!.ready.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'WebSocket connection timeout',
            const Duration(seconds: 10),
          );
        },
      );

      final connectionTime = DateTime.now().difference(_connectionStartTime!);

      // Connection successful
      _logger.i('✅ WebSocket connected successfully', {
        'url': wsUrl,
        'connectionTime': '${connectionTime.inMilliseconds}ms',
        'timestamp': DateTime.now().toIso8601String(),
        'channel': channel,
      });

      _updateConnectionState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;
      _messagesSent = 0;
      _messagesReceived = 0;

      // Start listening and heartbeat AFTER state update
      _listenToMessages();

      _logger.i('🎯 Connection setup complete', {
        'currentState': _currentState.toString(),
        'maxReconnectAttempts': _maxReconnectAttempts,
      });
    } catch (e, stackTrace) {
      final connectionTime =
          _connectionStartTime != null
              ? DateTime.now().difference(_connectionStartTime!)
              : null;

      _logger.e('❌ WebSocket connection failed', {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'channel': channel,
        'connectionTime':
            connectionTime != null
                ? '${connectionTime.inMilliseconds}ms'
                : 'unknown',
        'attemptNumber': _reconnectAttempts + 1,
        'stackTrace': stackTrace.toString(),
      });

      await _cleanupConnection();
      _updateConnectionState(WebSocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  void _updateConnectionState(WebSocketConnectionState state) {
    if (_currentState != state) {
      final previousState = _currentState;
      final timestamp = DateTime.now();
      _currentState = state;

      // IMPORTANT: Always notify listeners of state changes
      if (!_connectionController.isClosed) {
        _connectionController.add(state);
      }

      _logger.i('📡 WebSocket state transition', {
        'from': previousState.toString(),
        'to': state.toString(),
        'timestamp': timestamp.toIso8601String(),
        'connectionDuration': _getConnectionDuration(),
        'messageStats': {
          'sent': _messagesSent,
          'received': _messagesReceived,
          'lastMessageTime': _lastMessageTime?.toIso8601String(),
        },
      });
    }
  }

  void _listenToMessages() {
    if (_channel == null) {
      _logger.e('❌ Cannot listen to messages: channel is null');
      return;
    }

    _logger.i('👂 Starting WebSocket message listener', {
      'timestamp': DateTime.now().toIso8601String(),
      'channel': _currentChannel,
    });

    _channel!.stream.listen(
      (data) {
        final receiveTime = DateTime.now();
        _lastMessageTime = receiveTime;
        _messagesReceived++;

        try {
          _logger.d('📨 Raw WebSocket data received', {
            'dataType': data.runtimeType.toString(),
            'dataLength': data.toString().length,
            'timestamp': receiveTime.toIso8601String(),
            'messageCount': _messagesReceived,
          });

          final Map<String, dynamic> message = json.decode(data);
          final eventType = message['event'] ?? 'unknown';
          final messageData = message['data'];
          final messageId = message['id'];

          _logger.i('📬 WebSocket message received', {
            'event': eventType,
            'messageId': messageId,
            'hasData': messageData != null,
            'dataKeys': messageData is Map ? messageData.keys.toList() : null,
            'dataSize': messageData?.toString().length ?? 0,
            'timestamp': receiveTime.toIso8601String(),
            'totalReceived': _messagesReceived,
            'connectionDuration': _getConnectionDuration(),
          });

          // Log detailed data for specific events (you can customize this)
          if (_shouldLogDetailedData(eventType)) {
            _logger.d('📋 Message data details', {
              'event': eventType,
              'fullData': messageData,
              'rawMessage': message,
            });
          }

          _messageController.add(message);
        } catch (e, stackTrace) {
          _logger.e('🚫 Failed to parse WebSocket message', {
            'error': e.toString(),
            'errorType': e.runtimeType.toString(),
            'rawData': data.toString(),
            'dataLength': data.toString().length,
            'messageCount': _messagesReceived,
            'stackTrace': stackTrace.toString(),
          });
        }
      },
      onError: (error, stackTrace) {
        _logger.e('⚠️ WebSocket stream error', {
          'error': error.toString(),
          'errorType': error.runtimeType.toString(),
          'timestamp': DateTime.now().toIso8601String(),
          'connectionDuration': _getConnectionDuration(),
          'messageStats': {
            'sent': _messagesSent,
            'received': _messagesReceived,
          },
          'stackTrace': stackTrace?.toString(),
        });

        _updateConnectionState(WebSocketConnectionState.error);
        if (!_isManualDisconnect) {
          _scheduleReconnect();
        }
      },
      onDone: () {
        final disconnectTime = DateTime.now();

        _logger.i('🔚 WebSocket connection closed', {
          'timestamp': disconnectTime.toIso8601String(),
          'connectionDuration': _getConnectionDuration(),
          'isManualDisconnect': _isManualDisconnect,
          'finalStats': {
            'messagesSent': _messagesSent,
            'messagesReceived': _messagesReceived,
            'lastMessageTime': _lastMessageTime?.toIso8601String(),
          },
        });

        _updateConnectionState(WebSocketConnectionState.disconnected);
        if (!_isManualDisconnect) {
          _scheduleReconnect();
        }
      },
    );
  }

  void _scheduleReconnect() {
    if (_isManualDisconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      _logger.w('🔄 Reconnection cancelled', {
        'reason':
            _isManualDisconnect ? 'manual_disconnect' : 'max_attempts_reached',
        'attempts': _reconnectAttempts,
        'maxAttempts': _maxReconnectAttempts,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return;
    }

    _reconnectTimer?.cancel();

    _logger.i('⏰ Scheduling reconnection', {
      'delay': '${_reconnectDelay.inSeconds}s',
      'nextAttempt': _reconnectAttempts + 1,
      'maxAttempts': _maxReconnectAttempts,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      _logger.i('🔄 Executing reconnection attempt', {
        'attemptNumber': _reconnectAttempts,
        'channel': _currentChannel,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (_currentChannel != null) {
        connect(_currentToken, _currentChannel!);
      }
    });
  }

  void sendEvent(String event, Map<String, dynamic> data) {
    final sendTime = DateTime.now();

    if (_currentState != WebSocketConnectionState.connected) {
      _logger.w('⚠️ Cannot send message - WebSocket not connected', {
        'event': event,
        'currentState': _currentState.toString(),
        'timestamp': sendTime.toIso8601String(),
        'connectionDuration': _getConnectionDuration(),
      });
      return;
    }

    if (_channel == null) {
      _logger.e('❌ Cannot send message - channel is null', {
        'event': event,
        'timestamp': sendTime.toIso8601String(),
      });
      return;
    }

    try {
      final message = {
        'event': event,
        'data': data,
        'timestamp': sendTime.millisecondsSinceEpoch,
        'id': '${sendTime.millisecondsSinceEpoch}_${_messagesSent + 1}',
      };

      final jsonMessage = json.encode(message);
      _messagesSent++;

      _logger.i('📤 Sending WebSocket message', {
        'event': event,
        'messageId': message['id'],
        'dataKeys': data.keys.toList(),
        'messageSize': jsonMessage.length,
        'timestamp': sendTime.toIso8601String(),
        'totalSent': _messagesSent,
        'connectionDuration': _getConnectionDuration(),
      });

      // Log detailed data for specific events
      if (_shouldLogDetailedData(event)) {
        _logger.d('📋 Outgoing message data details', {
          'event': event,
          'fullData': data,
          'fullMessage': message,
          'jsonSize': jsonMessage.length,
        });
      }

      _channel!.sink.add(jsonMessage);
      _lastMessageTime = sendTime;

      _logger.d('✅ Message sent successfully', {
        'event': event,
        'messageId': message['id'],
        'timestamp': sendTime.toIso8601String(),
      });
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to send WebSocket message', {
        'event': event,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'data': data,
        'timestamp': sendTime.toIso8601String(),
        'stackTrace': stackTrace.toString(),
      });
    }
  }

  Future<void> _cleanupConnection() async {
    _logger.i('🧹 Cleaning up WebSocket connection', {
      'timestamp': DateTime.now().toIso8601String(),
      'connectionDuration': _getConnectionDuration(),
      'finalStats': {
        'messagesSent': _messagesSent,
        'messagesReceived': _messagesReceived,
      },
    });

    _reconnectTimer?.cancel();

    if (_channel != null) {
      try {
        await _channel!.sink.close();
        _logger.d('✅ WebSocket channel closed successfully');
      } catch (e) {
        _logger.e('❌ Error closing WebSocket channel', {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        });
      }
      _channel = null;
    }
  }

  void disconnect() {
    _logger.i('🔌 Manual WebSocket disconnection initiated', {
      'timestamp': DateTime.now().toIso8601String(),
      'connectionDuration': _getConnectionDuration(),
      'finalStats': {
        'messagesSent': _messagesSent,
        'messagesReceived': _messagesReceived,
        'lastMessageTime': _lastMessageTime?.toIso8601String(),
      },
    });

    _isManualDisconnect = true;
    _cleanupConnection().then((_) {
      _updateConnectionState(WebSocketConnectionState.disconnected);
      _currentChannel = null;
      _currentToken = null;

      _logger.i('✅ Manual disconnection completed', {
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  void dispose() {
    _logger.i('🗑️ Disposing WebSocket client', {
      'timestamp': DateTime.now().toIso8601String(),
      'totalLifetimeStats': {
        'messagesSent': _messagesSent,
        'messagesReceived': _messagesReceived,
        'connectionDuration': _getConnectionDuration(),
        'reconnectAttempts': _reconnectAttempts,
      },
    });

    disconnect();
    _messageController.close();
    _connectionController.close();
  }

  // Helper methods
  String? _getConnectionDuration() {
    if (_connectionStartTime == null) return null;
    final duration = DateTime.now().difference(_connectionStartTime!);
    return '${duration.inSeconds}s';
  }

  bool _shouldLogDetailedData(String event) {
    // Customize this to control which events should have detailed data logging
    // You might want to avoid logging sensitive data for certain events
    const sensitiveEvents = ['auth', 'login', 'token'];
    const alwaysLogEvents = ['ping', 'pong', 'error', 'disconnect'];

    if (sensitiveEvents.contains(event.toLowerCase())) {
      return false; // Don't log sensitive data
    }

    if (alwaysLogEvents.contains(event.toLowerCase())) {
      return true; // Always log these events
    }

    // For other events, you can add custom logic here
    return true; // Default: log detailed data
  }

  // Enhanced utility method for debugging with more stats
  Map<String, dynamic> getConnectionStats() {
    return {
      'currentState': _currentState.toString(),
      'channel': _currentChannel,
      'reconnectAttempts': _reconnectAttempts,
      'isManualDisconnect': _isManualDisconnect,
      'hasChannel': _channel != null,
      'connectionStartTime': _connectionStartTime?.toIso8601String(),
      'connectionDuration': _getConnectionDuration(),
      'messageStats': {
        'sent': _messagesSent,
        'received': _messagesReceived,
        'lastMessageTime': _lastMessageTime?.toIso8601String(),
      },
      'configuration': {
        'maxReconnectAttempts': _maxReconnectAttempts,
        'reconnectDelay': '${_reconnectDelay.inSeconds}s',
      },
    };
  }

  // Method to get detailed message statistics
  Map<String, dynamic> getMessageStats() {
    return {
      'sent': _messagesSent,
      'received': _messagesReceived,
      'lastMessageTime': _lastMessageTime?.toIso8601String(),
      'connectionDuration': _getConnectionDuration(),
      'messagesPerMinute': _getMessagesPerMinute(),
    };
  }

  double? _getMessagesPerMinute() {
    if (_connectionStartTime == null) return null;
    final duration = DateTime.now().difference(_connectionStartTime!);
    if (duration.inMinutes <= 0) return null;

    final totalMessages = _messagesSent + _messagesReceived;
    return totalMessages / duration.inMinutes;
  }
}
