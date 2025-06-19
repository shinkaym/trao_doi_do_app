import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/multi_websocket_manager.dart';
import 'package:trao_doi_do_app/data/datasources/remote/multi_websocket_remote_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/multi_websocket_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/multi_websocket_repository.dart';

// Import old providers for backward compatibility
import 'package:trao_doi_do_app/core/network/websocket_client.dart';
import 'package:trao_doi_do_app/data/datasources/remote/websocket_remote_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/websocket_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/websocket_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/websocket_usecases.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/chat_websocket_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/notification_websocket_provider.dart';
import '../modules/core_module.dart';
import '../modules/auth_module.dart';

/// WebSocket Module - Contains WebSocket-related dependencies
class WebSocketModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

// =============================================================================
// NEW MULTI-WEBSOCKET PROVIDERS
// =============================================================================

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

// Notification WebSocket Provider
final notificationWebSocketProvider = StateNotifierProvider.autoDispose<
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
    final notificationNotifier = ref.read(
      notificationWebSocketProvider.notifier,
    );

    // Auto connect when user logs in
    if (next.isLoggedIn &&
        next.user != null &&
        (previous?.isLoggedIn != true)) {
      _autoConnectBoth(ref, chatNotifier, notificationNotifier);
    }

    // Auto disconnect when user logs out
    if (!next.isLoggedIn && (previous?.isLoggedIn == true)) {
      chatNotifier.disconnect();
      notificationNotifier.disconnect();
    }
  });

  return {
    'chat': ref.read(chatWebSocketProvider.notifier),
    'notification': ref.read(notificationWebSocketProvider.notifier),
  };
});

// =============================================================================
// OLD PROVIDERS (For Backward Compatibility)
// =============================================================================

final chatWebSocketClientProvider = Provider.autoDispose<WebSocketClient>((
  ref,
) {
  final client = WebSocketClient();
  ref.onDispose(() {
    client.dispose();
  });
  return client;
});

final notificationWebSocketClientProvider =
    Provider.autoDispose<WebSocketClient>((ref) {
      final client = WebSocketClient();
      ref.onDispose(() {
        client.dispose();
      });
      return client;
    });

final webSocketRemoteDataSourceProvider =
    Provider.autoDispose<WebSocketRemoteDataSource>((ref) {
      final chatClient = ref.watch(chatWebSocketClientProvider);
      final notificationClient = ref.watch(notificationWebSocketClientProvider);
      return WebSocketRemoteDataSourceImpl(chatClient, notificationClient);
    });

final webSocketRepositoryProvider = Provider.autoDispose<WebSocketRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(webSocketRemoteDataSourceProvider);
  return WebSocketRepositoryImpl(remoteDataSource);
});

// Use cases
final connectToChatUseCaseProvider = Provider.autoDispose<ConnectToChatUseCase>(
  (ref) {
    final repository = ref.watch(webSocketRepositoryProvider);
    return ConnectToChatUseCase(repository);
  },
);

final connectToNotificationUseCaseProvider =
    Provider.autoDispose<ConnectToNotificationUseCase>((ref) {
      final repository = ref.watch(webSocketRepositoryProvider);
      return ConnectToNotificationUseCase(repository);
    });

final disconnectWebSocketUseCaseProvider =
    Provider.autoDispose<DisconnectWebSocketUseCase>((ref) {
      final repository = ref.watch(webSocketRepositoryProvider);
      return DisconnectWebSocketUseCase(repository);
    });

final joinRoomUseCaseProvider = Provider.autoDispose<JoinRoomUseCase>((ref) {
  final repository = ref.watch(webSocketRepositoryProvider);
  return JoinRoomUseCase(repository);
});

final leftRoomUseCaseProvider = Provider.autoDispose<LeftRoomUseCase>((ref) {
  final repository = ref.watch(webSocketRepositoryProvider);
  return LeftRoomUseCase(repository);
});

final sendMessageUseCaseProvider = Provider.autoDispose<SendMessageUseCase>((
  ref,
) {
  final repository = ref.watch(webSocketRepositoryProvider);
  return SendMessageUseCase(repository);
});

final getWebSocketResponseStreamUseCaseProvider =
    Provider.autoDispose<GetWebSocketResponseStreamUseCase>((ref) {
      final repository = ref.watch(webSocketRepositoryProvider);
      return GetWebSocketResponseStreamUseCase(repository);
    });

final getWebSocketConnectionStreamUseCaseProvider =
    Provider.autoDispose<GetWebSocketConnectionStreamUseCase>((ref) {
      final repository = ref.watch(webSocketRepositoryProvider);
      return GetWebSocketConnectionStreamUseCase(repository);
    });

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Helper function for new multi-websocket auto-connection
void _autoConnectBoth(
  ProviderRef ref,
  ChatWebSocketNotifier chatNotifier,
  NotificationWebSocketNotifier notificationNotifier,
) {
  ref
      .read(authLocalDataSourceProvider)
      .getAccessToken()
      .then((token) {
        if (token != null) {
          chatNotifier.connect(token);
          notificationNotifier.connect(token);
        }
      })
      .catchError((error) {
        ref.read(loggerProvider).e('Auto-connection failed: $error');
      });
}
