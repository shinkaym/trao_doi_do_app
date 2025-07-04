import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/multi_websocket_manager.dart';
import 'package:trao_doi_do_app/data/datasources/remote/multi_websocket_remote_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/multi_websocket_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/multi_websocket_repository.dart';

import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/chat_websocket_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/chat_notification_websocket_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/notification_websocket_provider.dart';
import '../modules/core_module.dart';
import '../modules/auth_module.dart';

/// WebSocket Module - Contains WebSocket-related dependencies
class WebSocketModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

final multiWebSocketManagerProvider =
    Provider.autoDispose<MultiWebSocketManager>((ref) {
      final manager = MultiWebSocketManager();
      ref.onDispose(() {
        manager.dispose();
      });
      return manager;
    });

final multiWebSocketRemoteDataSourceProvider =
    Provider.autoDispose<MultiWebSocketRemoteDataSource>((ref) {
      final manager = ref.watch(multiWebSocketManagerProvider);
      return MultiWebSocketRemoteDataSourceImpl(manager);
    });

final multiWebSocketRepositoryProvider =
    Provider.autoDispose<MultiWebSocketRepository>((ref) {
      final remoteDataSource = ref.watch(
        multiWebSocketRemoteDataSourceProvider,
      );
      return MultiWebSocketRepositoryImpl(remoteDataSource);
    });

// Chat WebSocket Provider
final chatWebSocketProvider = StateNotifierProvider.autoDispose<
  ChatWebSocketNotifier,
  ChatWebSocketState
>((ref) {
  final repository = ref.watch(multiWebSocketRepositoryProvider);
  final notifier = ChatWebSocketNotifier(repository);

  ref.onDispose(() {
    notifier.disconnect();
  });

  return notifier;
});

// ChatNotification WebSocket Provider
final chatNotificationWebSocketProvider = StateNotifierProvider<
  ChatNotificationWebSocketNotifier,
  ChatNotificationWebSocketState
>((ref) {
  final repository = ref.watch(multiWebSocketRepositoryProvider);
  final notifier = ChatNotificationWebSocketNotifier(repository);

  ref.onDispose(() {
    notifier.disconnect();
  });

  return notifier;
});

// Notification WebSocket Provider
final notificationWebSocketProvider = StateNotifierProvider<
  NotificationWebSocketNotifier,
  NotificationWebSocketState
>((ref) {
  final repository = ref.watch(multiWebSocketRepositoryProvider);
  final notifier = NotificationWebSocketNotifier(repository);

  ref.onDispose(() {
    notifier.disconnect();
  });

  return notifier;
});

// Auto Connection Management Provider
final multiWebSocketConnectionProvider = Provider.autoDispose((ref) {
  ref.keepAlive();

  // Listen to auth state changes
  ref.listen<AuthState>(authProvider, (previous, next) {
    final chatNotifier = ref.read(chatWebSocketProvider.notifier);
    final chatNotificationNotifier = ref.read(
      chatNotificationWebSocketProvider.notifier,
    );
    final notificationNotifier = ref.read(
      notificationWebSocketProvider.notifier,
    );

    // Auto connect when user logs in
    if (next.isLoggedIn &&
        next.user != null &&
        (previous?.isLoggedIn != true)) {
      _autoConnectAll(
        ref,
        chatNotifier,
        chatNotificationNotifier,
        notificationNotifier,
      );
    }

    // Auto disconnect when user logs out
    if (!next.isLoggedIn && (previous?.isLoggedIn == true)) {
      chatNotifier.disconnect();
      chatNotificationNotifier.disconnect();
      notificationNotifier.disconnect();
    }
  });

  return {
    'chat': ref.read(chatWebSocketProvider.notifier),
    'chatNotification': ref.read(chatNotificationWebSocketProvider.notifier),
    'notification': ref.read(notificationWebSocketProvider.notifier),
  };
});

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Helper function for new multi-websocket auto-connection
void _autoConnectAll(
  ProviderRef ref,
  ChatWebSocketNotifier chatNotifier,
  ChatNotificationWebSocketNotifier chatNotificationNotifier,
  NotificationWebSocketNotifier notificationNotifier,
) {
  ref
      .read(authLocalDataSourceProvider)
      .getAccessToken()
      .then((token) {
        if (token != null) {
          chatNotifier.connect(token);
          chatNotificationNotifier.connect(token);
          notificationNotifier.connect(token);
        }
      })
      .catchError((error) {
        ref.read(loggerProvider).e('Auto-connection failed: $error');
      });
}
