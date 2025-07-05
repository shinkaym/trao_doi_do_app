import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/multi_websocket_manager.dart';
import 'package:trao_doi_do_app/data/datasources/remote/multi_websocket_remote_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/multi_websocket_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/multi_websocket_repository.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/chat_websocket_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/chat_notification_websocket_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/notification_websocket_provider.dart';
import '../modules/auth_module.dart';

class WebSocketModule {
  static void initialize() {}
}

final multiWebSocketManagerProvider = Provider<MultiWebSocketManager>((ref) {
  final manager = MultiWebSocketManager();
  ref.onDispose(() {
    manager.dispose();
  });
  return manager;
});

final multiWebSocketRemoteDataSourceProvider =
    Provider<MultiWebSocketRemoteDataSource>((ref) {
      final manager = ref.watch(multiWebSocketManagerProvider);
      return MultiWebSocketRemoteDataSourceImpl(manager);
    });

final multiWebSocketRepositoryProvider = Provider<MultiWebSocketRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(multiWebSocketRemoteDataSourceProvider);
  return MultiWebSocketRepositoryImpl(remoteDataSource);
});

final chatWebSocketProvider =
    StateNotifierProvider<ChatWebSocketNotifier, ChatWebSocketState>((ref) {
      final repository = ref.watch(multiWebSocketRepositoryProvider);
      final notifier = ChatWebSocketNotifier(repository);
      ref.onDispose(() {
        notifier.disconnect();
      });
      return notifier;
    });

final chatNotificationWebSocketProvider = StateNotifierProvider.autoDispose<
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

final multiWebSocketConnectionProvider = Provider.autoDispose((ref) {
  ref.keepAlive();

  Future<void> _connectAll(String token) async {
    try {
      await ref.read(multiWebSocketRepositoryProvider).connectAll(token);
      ref.read(multiWebSocketManagerProvider);
    } catch (e) {
      // Log error or handle appropriately
    }
  }

  void _disconnectAll() {
    ref.read(multiWebSocketRepositoryProvider).disconnectAll();
  }

  ref.listen<AuthState>(authProvider, (previous, next) async {
    if (next.isLoggedIn && (previous?.isLoggedIn != true)) {
      final getAccessTokenUseCase = ref.read(getAccessTokenUseCaseProvider);
      final result = await getAccessTokenUseCase.execute();
      result.fold((failure) {}, (token) {
        if (token != null) {
          _connectAll(token);
        }
      });
    }

    if (!next.isLoggedIn && (previous?.isLoggedIn == true)) {
      _disconnectAll();
    }
  });

  return {
    'chat': ref.read(chatWebSocketProvider.notifier),
    'chatNotification': ref.read(chatNotificationWebSocketProvider.notifier),
    'notification': ref.read(notificationWebSocketProvider.notifier),
  };
});
