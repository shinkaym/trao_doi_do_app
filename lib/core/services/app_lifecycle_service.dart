import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  final Ref _ref;
  bool _isAppInForeground = true;

  AppLifecycleService(this._ref) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state if necessary
        print('App hidden');
        break;
    }
  }

  void _handleAppResumed() {
    print('App resumed - foreground');
    _isAppInForeground = true;
    
    // Connect WebSocket when app comes to foreground
    final authState = _ref.read(authProvider);
    if (authState.isLoggedIn) {
      _connectWebSocketsAfterResume();
    }
  }

  void _handleAppPaused() {
    print('App paused - background');
    _isAppInForeground = false;
    
    // WebSocket will continue running for real-time notifications
    // FCM will handle notifications when app is in background
  }

  void _handleAppInactive() {
    print('App inactive');
    // App is transitioning between foreground and background
  }

  void _handleAppDetached() {
    print('App detached');
    // App is being terminated
  }

  Future<void> _connectWebSocketsAfterResume() async {
    try {
      final getAccessTokenUseCase = _ref.read(getAccessTokenUseCaseProvider);
      final result = await getAccessTokenUseCase.execute();
      
      result.fold(
        (failure) {
          print('Failed to get access token for WebSocket reconnection');
        },
        (token) async {
          if (token != null) {
            // Check if WebSockets are already connected
            final wsManager = _ref.read(multiWebSocketRepositoryProvider);
            final connectionSummary = wsManager.getConnectionSummary();
            
            if (!connectionSummary['allConnected']) {
              await wsManager.connectAll(token);
            }
          }
        },
      );
    } catch (e) {
      print('Error reconnecting WebSockets after app resume: $e');
    }
  }

  bool get isAppInForeground => _isAppInForeground;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}