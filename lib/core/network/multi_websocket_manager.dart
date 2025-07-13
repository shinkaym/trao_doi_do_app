import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';

enum WebSocketChannel { chat, chatNotification, notification }

class MultiWebSocketManager {
  final Map<WebSocketChannel, WebSocketClient> _clients = {};
  final StreamController<WebSocketResponse> _responseController =
      StreamController<WebSocketResponse>.broadcast();
  final StreamController<Map<WebSocketChannel, WebSocketConnectionState>>
  _connectionController =
      StreamController<
        Map<WebSocketChannel, WebSocketConnectionState>
      >.broadcast();

  final Map<WebSocketChannel, StreamSubscription> _messageSubscriptions = {};
  final Map<WebSocketChannel, StreamSubscription> _connectionSubscriptions = {};

  // Connectivity monitoring
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<dynamic>? _connectivitySubscription;
  bool _hasInternetConnection = true;
  Timer? _networkRestoreTimer;

  // Store connection info for reconnection
  String? _currentToken;
  final Map<WebSocketChannel, String> _endpoints = {
    WebSocketChannel.chat: '/chat',
    WebSocketChannel.chatNotification: '/chat-noti',
    WebSocketChannel.notification: '/noti',
  };

  // Connection monitoring
  Timer? _connectionMonitorTimer;
  bool _isDisposed = false;

  Stream<WebSocketResponse> get responseStream => _responseController.stream;
  Stream<Map<WebSocketChannel, WebSocketConnectionState>>
  get connectionStream => _connectionController.stream;

  Stream<WebSocketResponse> get chatResponseStream =>
      responseStream.where((response) => response.sourceChannel == 'chat');

  Stream<WebSocketResponse> get chatNotificationResponseStream =>
      responseStream.where((response) => response.sourceChannel == 'chat-noti');

  Stream<WebSocketResponse> get notificationResponseStream =>
      responseStream.where((response) => response.sourceChannel == 'noti');

  // Network status stream
  Stream<bool> get networkStatusStream =>
      _connectivity.onConnectivityChanged.map((result) {
        return _parseConnectivityResult(result);
      });

  bool get hasInternetConnection => _hasInternetConnection;

  MultiWebSocketManager() {
    _clients[WebSocketChannel.chat] = WebSocketClient();
    _clients[WebSocketChannel.chatNotification] = WebSocketClient();
    _clients[WebSocketChannel.notification] = WebSocketClient();
    _initializeConnectivityMonitoring();
    _updateConnectionStates();
    _startConnectionMonitoring();
  }

  void _initializeConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (dynamic result) {
        _handleConnectivityChange(result);
      },
      onError: (error) {
        print('Connectivity subscription error: $error');
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
      print('Initial connectivity check failed: $e');
      // If connectivity check fails, assume we have connection
      _hasInternetConnection = true;
    }
  }

  bool _parseConnectivityResult(dynamic result) {
    try {
      if (result is List<ConnectivityResult>) {
        return result.any((r) => r != ConnectivityResult.none);
      } else if (result is ConnectivityResult) {
        return result != ConnectivityResult.none;
      } else if (result is List) {
        // Handle case where result is a List but not specifically List<ConnectivityResult>
        bool hasConnection = false;
        for (var r in result) {
          if (r is ConnectivityResult) {
            if (r != ConnectivityResult.none) {
              hasConnection = true;
              break;
            }
          } else if (r is String) {
            // Handle string representation
            if (!r.toLowerCase().contains('none')) {
              hasConnection = true;
              break;
            }
          }
        }
        return hasConnection;
      } else if (result is String) {
        // Handle string representation directly
        String resultStr = result.toLowerCase();
        return !resultStr.contains('none') &&
            (resultStr.contains('wifi') ||
                resultStr.contains('mobile') ||
                resultStr.contains('ethernet') ||
                resultStr.contains('vpn') ||
                resultStr.contains('bluetooth') ||
                resultStr.contains('other'));
      } else {
        // For any other type, try to parse as string or assume connection
        String resultStr = result.toString().toLowerCase();
        return !resultStr.contains('none') && resultStr.isNotEmpty;
      }
    } catch (e) {
      print(
        'Error parsing connectivity result: $e, type: ${result.runtimeType}',
      );
      return true; // Default to connected for unknown types
    }
  }

  void _handleConnectivityChange(dynamic result) {
    bool hasConnection = _parseConnectivityResult(result);

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

    _responseController.add(
      WebSocketResponse.fromJson({
        'event': 'network_disconnected',
        'message': 'Network connection lost',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }).copyWithSourceChannel(sourceChannel: 'system'),
    );
  }

  void _onNetworkRestored() {
    if (_isDisposed) return;

    _responseController.add(
      WebSocketResponse.fromJson({
        'event': 'network_restored',
        'message': 'Network connection restored',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }).copyWithSourceChannel(sourceChannel: 'system'),
    );

    // Wait a bit for network to stabilize, then reconnect all channels
    _networkRestoreTimer?.cancel();
    _networkRestoreTimer = Timer(Duration(seconds: 3), () {
      if (!_isDisposed && _currentToken != null) {
        _reconnectAllAfterNetworkRestore();
      }
    });
  }

  Future<void> _reconnectAllAfterNetworkRestore() async {
    if (_isDisposed || _currentToken == null) return;

    try {
      await connectAll(_currentToken);
    } catch (e) {
      _responseController.addError(
        'Failed to reconnect after network restore: $e',
      );
    }
  }

  void _startConnectionMonitoring() {
    _connectionMonitorTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      // Only check and reconnect if we have internet connection
      if (_hasInternetConnection) {
        _checkAndReconnectDisconnectedChannels();
      }
    });
  }

  void _checkAndReconnectDisconnectedChannels() {
    if (_currentToken == null || !_hasInternetConnection) return;

    _clients.forEach((channel, client) async {
      if (client.currentState == WebSocketConnectionState.disconnected ||
          client.currentState == WebSocketConnectionState.error) {
        try {
          await _connectChannel(channel, _currentToken, _endpoints[channel]!);
        } catch (e) {
          // Log error but don't throw to avoid stopping other reconnections
          print('Failed to reconnect channel $channel: $e');
        }
      }
    });
  }

  Future<void> connectToChat(String? token) async {
    await _connectChannel(WebSocketChannel.chat, token, '/chat');
  }

  Future<void> connectToChatNotification(String? token) async {
    await _connectChannel(
      WebSocketChannel.chatNotification,
      token,
      '/chat-noti',
    );
  }

  Future<void> connectToNotification(String? token) async {
    await _connectChannel(WebSocketChannel.notification, token, '/noti');
  }

  Future<void> connectAll(String? token) async {
    _currentToken = token;

    if (!_hasInternetConnection) {
      _responseController.addError('Cannot connect: no internet connection');
      return;
    }

    try {
      await Future.wait([
        connectToChat(token),
        connectToChatNotification(token),
        connectToNotification(token),
      ], eagerError: false);
    } catch (e) {
      _responseController.addError('Failed to connect all channels: $e');
    }
  }

  Future<void> _connectChannel(
    WebSocketChannel channel,
    String? token,
    String endpoint,
  ) async {
    if (_isDisposed) return;

    final client = _clients[channel]!;
    _setupChannelSubscriptions(channel);

    try {
      await client.connect(token, endpoint);
    } catch (e) {
      _responseController.addError('Failed to connect $channel: $e');
      rethrow;
    }
  }

  void _setupChannelSubscriptions(WebSocketChannel channel) {
    final client = _clients[channel]!;

    _messageSubscriptions[channel]?.cancel();
    _connectionSubscriptions[channel]?.cancel();

    _messageSubscriptions[channel] = client.messageStream.listen(
      (data) {
        final response = WebSocketResponse.fromJson(data);
        String sourceChannel;
        switch (channel) {
          case WebSocketChannel.chat:
            sourceChannel = 'chat';
            break;
          case WebSocketChannel.chatNotification:
            sourceChannel = 'chat-noti';
            break;
          case WebSocketChannel.notification:
            sourceChannel = 'noti';
            break;
        }
        final taggedResponse = response.copyWithSourceChannel(
          sourceChannel: sourceChannel,
        );
        _responseController.add(taggedResponse);
      },
      onError: (error) {
        _responseController.addError('Message error on $channel: $error');
      },
    );

    _connectionSubscriptions[channel] = client.connectionStream.listen(
      (state) {
        _updateConnectionStates();
      },
      onError: (error) {
        _responseController.addError('Connection error on $channel: $error');
      },
    );
  }

  void _updateConnectionStates() {
    if (_isDisposed) return;

    final states = {
      for (var channel in _clients.keys)
        channel: _clients[channel]!.currentState,
    };
    _connectionController.add(states);
  }

  void sendChatEvent(String event, Map<String, dynamic> data) {
    if (!_hasInternetConnection) {
      _responseController.addError(
        'Cannot send chat event: no internet connection',
      );
      return;
    }
    _clients[WebSocketChannel.chat]?.sendEvent(event, data);
  }

  void sendChatNotificationEvent(String event, Map<String, dynamic> data) {
    if (!_hasInternetConnection) {
      _responseController.addError(
        'Cannot send chat notification event: no internet connection',
      );
      return;
    }
    _clients[WebSocketChannel.chatNotification]?.sendEvent(event, data);
  }

  void sendNotificationEvent(String event, Map<String, dynamic> data) {
    if (!_hasInternetConnection) {
      _responseController.addError(
        'Cannot send notification event: no internet connection',
      );
      return;
    }
    _clients[WebSocketChannel.notification]?.sendEvent(event, data);
  }

  WebSocketConnectionState getChatConnectionState() {
    return _clients[WebSocketChannel.chat]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  WebSocketConnectionState getChatNotificationConnectionState() {
    return _clients[WebSocketChannel.chatNotification]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  WebSocketConnectionState getNotificationConnectionState() {
    return _clients[WebSocketChannel.notification]?.currentState ??
        WebSocketConnectionState.disconnected;
  }

  void disconnectChat() {
    _clients[WebSocketChannel.chat]?.disconnect();
    _updateConnectionStates();
  }

  void disconnectChatNotification() {
    _clients[WebSocketChannel.chatNotification]?.disconnect();
    _updateConnectionStates();
  }

  void disconnectNotification() {
    _clients[WebSocketChannel.notification]?.disconnect();
    _updateConnectionStates();
  }

  void disconnectAll() {
    _clients.values.forEach((client) => client.disconnect());
    _updateConnectionStates();
  }

  // Manual reconnection methods
  Future<void> reconnectAll() async {
    if (_currentToken == null) return;

    if (!_hasInternetConnection) {
      _responseController.addError('Cannot reconnect: no internet connection');
      return;
    }

    await Future.wait([
      _clients[WebSocketChannel.chat]!.reconnect(),
      _clients[WebSocketChannel.chatNotification]!.reconnect(),
      _clients[WebSocketChannel.notification]!.reconnect(),
    ], eagerError: false);
  }

  Future<void> reconnectChannel(WebSocketChannel channel) async {
    if (!_hasInternetConnection) {
      _responseController.addError(
        'Cannot reconnect channel: no internet connection',
      );
      return;
    }
    await _clients[channel]?.reconnect();
  }

  // Update token for all connections
  void updateToken(String? newToken) {
    _currentToken = newToken;
  }

  // Force check connectivity for all clients
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange(result);

      // Also check connectivity for all individual clients
      for (final client in _clients.values) {
        await client.checkConnectivity();
      }
    } catch (e) {
      _responseController.addError('Error checking connectivity: $e');
    }
  }

  // Get connection status summary
  Map<String, dynamic> getConnectionSummary() {
    return {
      'hasInternetConnection': _hasInternetConnection,
      'chat': _clients[WebSocketChannel.chat]?.currentState.toString(),
      'chatNotification':
          _clients[WebSocketChannel.chatNotification]?.currentState.toString(),
      'notification':
          _clients[WebSocketChannel.notification]?.currentState.toString(),
      'allConnected':
          _hasInternetConnection &&
          _clients.values.every(
            (client) =>
                client.currentState == WebSocketConnectionState.connected,
          ),
      'networkStatus': {
        for (var entry in _clients.entries)
          entry.key.toString(): entry.value.getNetworkStatus(),
      },
    };
  }

  // Get detailed network status
  Map<String, dynamic> getNetworkStatus() {
    return {
      'hasInternetConnection': _hasInternetConnection,
      'clients': {
        for (var entry in _clients.entries)
          entry.key.toString(): entry.value.getNetworkStatus(),
      },
    };
  }

  void dispose() {
    _isDisposed = true;
    _connectivitySubscription?.cancel();
    _connectionMonitorTimer?.cancel();
    _networkRestoreTimer?.cancel();
    _messageSubscriptions.values.forEach((sub) => sub.cancel());
    _connectionSubscriptions.values.forEach((sub) => sub.cancel());
    _clients.values.forEach((client) => client.dispose());
    _responseController.close();
    _connectionController.close();
  }
}
