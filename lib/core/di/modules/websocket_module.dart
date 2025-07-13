import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/network/multi_websocket_manager.dart';
import 'package:trao_doi_do_app/data/datasources/remote/multi_websocket_remote_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/multi_websocket_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/multi_websocket_repository.dart';
import 'package:trao_doi_do_app/presentation/notifiers/chat_websocket_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/chat_notification_websocket_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/notification_websocket_notifier.dart';

class WebSocketModule {
  static void initialize() {}
}

final multiWebSocketManagerProvider = Provider<MultiWebSocketManager>((ref) {
  final manager = MultiWebSocketManager(ref);
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
