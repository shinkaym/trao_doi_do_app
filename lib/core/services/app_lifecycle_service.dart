import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  final Ref ref;
  bool _isAppInForeground = true;

  AppLifecycleService(this.ref) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final logger = ref.read(loggerProvider);

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
        logger.i('🔒 App lifecycle: Hidden');
        break;
    }
  }

  void _handleAppResumed() {
    final logger = ref.read(loggerProvider);
    logger.i('🌟 App lifecycle: Resumed - App in foreground');
    _isAppInForeground = true;

    // Connect WebSocket when app comes to foreground
    final authState = ref.read(authProvider);
    if (authState.isLoggedIn) {
      logger.i('🔌 Attempting to reconnect WebSockets after app resume');
      _connectWebSocketsAfterResume();
    }
  }

  void _handleAppPaused() {
    final logger = ref.read(loggerProvider);
    logger.i('⏸️ App lifecycle: Paused - App in background');
    _isAppInForeground = false;

    // WebSocket will continue running for real-time notifications
    // FCM will handle notifications when app is in background
    logger.d('📱 FCM will handle notifications while app is in background');
  }

  void _handleAppInactive() {
    final logger = ref.read(loggerProvider);
    logger.i('😴 App lifecycle: Inactive - App transitioning');
    // App is transitioning between foreground and background
  }

  void _handleAppDetached() {
    final logger = ref.read(loggerProvider);
    logger.i('🔚 App lifecycle: Detached - App terminating');
    // App is being terminated
  }

  Future<void> _connectWebSocketsAfterResume() async {
    final logger = ref.read(loggerProvider);

    try {
      logger.d('🔑 Getting access token for WebSocket reconnection...');
      final getAccessTokenUseCase = ref.read(getAccessTokenUseCaseProvider);
      final result = await getAccessTokenUseCase.execute();

      result.fold(
        (failure) {
          logger.w(
            '❌ Failed to get access token for WebSocket reconnection',
            failure,
          );
        },
        (token) async {
          if (token != null) {
            logger.d(
              '✅ Access token obtained, checking WebSocket connections...',
            );

            // Check if WebSockets are already connected
            final wsManager = ref.read(multiWebSocketRepositoryProvider);
            final connectionSummary = wsManager.getConnectionSummary();

            logger.d('📊 WebSocket connection summary', connectionSummary);

            if (!connectionSummary['allConnected']) {
              logger.i('🔄 Reconnecting WebSockets...');
              await wsManager.connectAll(token);
              logger.i('✅ WebSockets reconnected successfully');
            } else {
              logger.i('✅ WebSockets already connected');
            }
          } else {
            logger.w('⚠️ No access token available for WebSocket reconnection');
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        '❌ Error reconnecting WebSockets after app resume',
        e,
        stackTrace,
      );
    }
  }

  bool get isAppInForeground => _isAppInForeground;

  void dispose() {
    final logger = ref.read(loggerProvider);
    logger.i('🧹 Disposing AppLifecycleService');
    WidgetsBinding.instance.removeObserver(this);
  }
}
