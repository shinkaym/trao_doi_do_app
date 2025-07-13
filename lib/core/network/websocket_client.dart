import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/config/flavor.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WebSocketConnectionState { connecting, connected, disconnected, error }

class WebSocketClient {
  final Ref ref;
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketConnectionState> _stateController =
      StreamController<WebSocketConnectionState>.broadcast();
  WebSocketConnectionState _currentState =
      WebSocketConnectionState.disconnected;
  Timer? _pingTimer;
  Timer? _timeoutTimer;
  Timer? _reconnectTimer;

  // Connectivity monitoring
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<dynamic>? _connectivitySubscription;
  bool _hasInternetConnection = true;
  bool _wasDisconnectedDueToNetwork = false;

  // Store connection info for reconnection
  String? _token;
  String? _endpoint;

  // Reconnection configuration
  static const Duration _pingInterval = Duration(seconds: 30);
  static const Duration _timeoutDuration = Duration(seconds: 60);
  static const Duration _initialReconnectDelay = Duration(seconds: 2);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);
  static const int _maxReconnectAttempts = 5;
  static const Duration _networkCheckDelay = Duration(seconds: 3);

  int _reconnectAttempts = 0;
  bool _shouldReconnect = true;
  bool _isDisposed = false;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<WebSocketConnectionState> get connectionStream =>
      _stateController.stream;
  WebSocketConnectionState get currentState => _currentState;
  bool get hasInternetConnection => _hasInternetConnection;

  WebSocketClient(this.ref) {
    _initializeConnectivityMonitoring();
  }

  void _initializeConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (dynamic results) {
        _handleConnectivityChange(results);
      },
      onError: (error) {
        final logger = ref.read(loggerProvider);
        logger.e('Connectivity subscription error', error);
        // Assume we have connection if we can't monitor it
        _hasInternetConnection = true;
      },
    );

    // Check initial connectivity
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange(result);
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('Initial connectivity check failed', e);
      // If connectivity check fails, assume we have connection
      _hasInternetConnection = true;
    }
  }

  void _handleConnectivityChange(dynamic results) {
    bool hasConnection = false;

    try {
      if (results is List<ConnectivityResult>) {
        hasConnection = results.any(
          (result) => result != ConnectivityResult.none,
        );
      } else if (results is ConnectivityResult) {
        hasConnection = results != ConnectivityResult.none;
      } else if (results is List) {
        // Handle case where results is a List but not specifically List<ConnectivityResult>
        hasConnection = results.isNotEmpty;
        for (var result in results) {
          if (result is ConnectivityResult) {
            if (result != ConnectivityResult.none) {
              hasConnection = true;
              break;
            }
          } else if (result is String) {
            // Handle string representation of connectivity result
            hasConnection = !result.toLowerCase().contains('none');
            if (hasConnection) break;
          }
        }
      } else if (results is String) {
        // Handle string representation directly
        String resultStr = results.toLowerCase();
        hasConnection =
            !resultStr.contains('none') &&
            (resultStr.contains('wifi') ||
                resultStr.contains('mobile') ||
                resultStr.contains('ethernet') ||
                resultStr.contains('vpn') ||
                resultStr.contains('bluetooth') ||
                resultStr.contains('other'));
      } else {
        // For any other type, try to parse as string
        String resultStr = results.toString().toLowerCase();
        hasConnection = !resultStr.contains('none') && resultStr.isNotEmpty;
      }
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('Error parsing connectivity result', {
        'error': e,
        'type': results.runtimeType.toString(),
        'results': results.toString(),
      });
      // If we can't parse the connectivity result, assume we have connection
      hasConnection = true;
    }

    final previousConnectionState = _hasInternetConnection;
    _hasInternetConnection = hasConnection;

    if (!previousConnectionState && hasConnection) {
      // Internet connection restored
      _onNetworkRestored();
    } else if (previousConnectionState && !hasConnection) {
      // Internet connection lost
      _onNetworkLost();
    }
  }

  void _onNetworkLost() {
    if (_isDisposed) return;

    _wasDisconnectedDueToNetwork = true;
    if (_currentState == WebSocketConnectionState.connected) {
      _updateState(WebSocketConnectionState.disconnected);
      _messageController.add({
        'event': 'network_disconnected',
        'message': 'Network connection lost',
      });
    }
  }

  void _onNetworkRestored() {
    if (_isDisposed || !_shouldReconnect) return;

    _messageController.add({
      'event': 'network_restored',
      'message': 'Network connection restored',
    });

    if (_wasDisconnectedDueToNetwork &&
        _currentState == WebSocketConnectionState.disconnected) {
      _wasDisconnectedDueToNetwork = false;
      // Wait a bit for network to stabilize, then reconnect
      Timer(_networkCheckDelay, () {
        if (!_isDisposed && _shouldReconnect) {
          _attemptReconnectAfterNetworkRestore();
        }
      });
    }
  }

  Future<void> _attemptReconnectAfterNetworkRestore() async {
    if (_isDisposed || !_shouldReconnect) return;
    if (_token == null || _endpoint == null) return;

    // Reset reconnect attempts for network restoration
    _reconnectAttempts = 0;
    await connect(_token, _endpoint!);
  }

  Future<void> connect(String? token, String endpoint) async {
    if (_isDisposed) return;
    if (_currentState == WebSocketConnectionState.connected) return;

    // Check network connectivity before attempting connection
    if (!_hasInternetConnection) {
      _updateState(WebSocketConnectionState.error);
      _messageController.addError('No internet connection available');
      return;
    }

    // Store connection info for reconnection
    _token = token;
    _endpoint = endpoint;
    _shouldReconnect = true;

    _updateState(WebSocketConnectionState.connecting);
    try {
      final wsUrl = '${AppConfig.wsDomain}$endpoint';
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: token != null ? [token] : null,
      );

      await _channel!.ready;
      _updateState(WebSocketConnectionState.connected);

      // Reset reconnect attempts on successful connection
      _reconnectAttempts = 0;
      _wasDisconnectedDueToNetwork = false;

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
      _scheduleReconnect();
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _timeoutTimer?.cancel();

    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      // Check network connectivity before sending ping
      if (!_hasInternetConnection) {
        timer.cancel();
        _onNetworkLost();
        return;
      }

      sendEvent('ping', {});
      _resetTimeoutTimer();
    });
  }

  void _resetTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_timeoutDuration, () {
      if (_isDisposed) return;
      _updateState(WebSocketConnectionState.disconnected);
      _scheduleReconnect();
    });
  }

  void _handleIncomingData(dynamic data) {
    if (_isDisposed) return;

    try {
      final message = json.decode(data.toString());

      // Log received message
      final logger = ref.read(loggerProvider);
      logger.i('🔽 WebSocket Received', {
        'endpoint': _endpoint,
        'event': message['event'],
        'data': message,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (message['event'] == 'keep_alive') {
        _updateState(WebSocketConnectionState.connected);
        _resetTimeoutTimer();
      } else {
        _messageController.add(message);
      }
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('Error parsing WebSocket message', {
        'endpoint': _endpoint,
        'error': e,
        'rawData': data.toString(),
      });
      _updateState(WebSocketConnectionState.error);
      _messageController.addError('Error parsing message: $e');
    }
  }

  void _handleError(dynamic error) {
    if (_isDisposed) return;

    final logger = ref.read(loggerProvider);
    logger.e('WebSocket Error', {
      'endpoint': _endpoint,
      'error': error,
      'connectionState': _currentState.toString(),
    });

    _updateState(WebSocketConnectionState.error);
    _stateController.addError('WebSocket error: $error');
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    if (_isDisposed) return;

    final logger = ref.read(loggerProvider);
    logger.w('WebSocket Disconnected', {
      'endpoint': _endpoint,
      'previousState': _currentState.toString(),
    });

    _updateState(WebSocketConnectionState.disconnected);
    _pingTimer?.cancel();
    _timeoutTimer?.cancel();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed || !_shouldReconnect) return;

    // Don't schedule reconnect if there's no internet connection
    if (!_hasInternetConnection) {
      _wasDisconnectedDueToNetwork = true;
      return;
    }

    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _updateState(WebSocketConnectionState.error);
      _messageController.addError('Max reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;

    // Exponential backoff with jitter
    final baseDelay = _initialReconnectDelay.inMilliseconds;
    final maxDelay = _maxReconnectDelay.inMilliseconds;
    final exponentialDelay = min(
      baseDelay * pow(2, _reconnectAttempts - 1),
      maxDelay,
    );
    final jitter = Random().nextInt(1000); // Add up to 1 second of jitter
    final delay = Duration(milliseconds: exponentialDelay.toInt() + jitter);

    _reconnectTimer = Timer(delay, () {
      if (_isDisposed || !_shouldReconnect) return;
      _attemptReconnect();
    });
  }

  Future<void> _attemptReconnect() async {
    if (_isDisposed || !_shouldReconnect) return;
    if (_token == null || _endpoint == null) return;

    // Double-check network connectivity before reconnecting
    if (!_hasInternetConnection) {
      _wasDisconnectedDueToNetwork = true;
      return;
    }

    await connect(_token, _endpoint!);
  }

  void _updateState(WebSocketConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      if (!_isDisposed) {
        _stateController.add(newState);
      }
    }
  }

  void sendEvent(String event, Map<String, dynamic> data) {
    if (_isDisposed) return;

    if (!_hasInternetConnection) {
      _messageController.addError('Cannot send event: no internet connection');
      return;
    }

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

      // Log sent message
      final logger = ref.read(loggerProvider);
      logger.i('🔼 WebSocket Sent', {
        'endpoint': _endpoint,
        'event': event,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _channel!.sink.add(message);
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('Error sending WebSocket event', {
        'endpoint': _endpoint,
        'event': event,
        'data': data,
        'error': e,
      });
      _messageController.addError('Error sending event: $e');
    }
  }

  void disconnect() {
    _shouldReconnect = false;
    _pingTimer?.cancel();
    _timeoutTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _updateState(WebSocketConnectionState.disconnected);
  }

  void dispose() {
    _isDisposed = true;
    _shouldReconnect = false;
    _connectivitySubscription?.cancel();
    disconnect();
    _messageController.close();
    _stateController.close();
  }

  // Method to manually trigger reconnection
  Future<void> reconnect() async {
    if (_isDisposed) return;

    if (!_hasInternetConnection) {
      _messageController.addError('Cannot reconnect: no internet connection');
      return;
    }

    _shouldReconnect = true;
    _reconnectAttempts = 0;
    _wasDisconnectedDueToNetwork = false;

    if (_currentState == WebSocketConnectionState.connected) {
      disconnect();
    }

    if (_token != null && _endpoint != null) {
      await connect(_token, _endpoint!);
    }
  }

  // Method to reset reconnection attempts
  void resetReconnectAttempts() {
    _reconnectAttempts = 0;
  }

  // Method to force check connectivity
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange(result);
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('Connectivity check failed', e);
      // If connectivity check fails, assume we have connection
      _hasInternetConnection = true;
    }
  }

  // Get network status info
  Map<String, dynamic> getNetworkStatus() {
    return {
      'hasInternetConnection': _hasInternetConnection,
      'wasDisconnectedDueToNetwork': _wasDisconnectedDueToNetwork,
      'connectionState': _currentState.toString(),
      'reconnectAttempts': _reconnectAttempts,
    };
  }
}
