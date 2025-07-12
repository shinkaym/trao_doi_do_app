import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/notification_socket.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/notification/widgets/connection_status_widget.dart';
import 'package:trao_doi_do_app/presentation/features/notification/widgets/end_of_list_item.dart';
import 'package:trao_doi_do_app/presentation/features/notification/widgets/notification_item.dart';
import 'package:trao_doi_do_app/presentation/features/notification/widgets/notifications_skeleton.dart';
import 'package:trao_doi_do_app/presentation/features/notification/widgets/websocket_notification_item.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/ranking/loading_item.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';
import 'package:trao_doi_do_app/domain/entities/notification.dart' as entities;
import 'package:flutter_debouncer/flutter_debouncer.dart';

class NotificationScreen extends HookConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final notificationState = ref.watch(notificationProvider);
    final websocketState = ref.watch(notificationWebSocketProvider);
    final isReconnecting = useState(false);
    final getAccessTokenUseCase = ref.read(getAccessTokenUseCaseProvider);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    // Get combined notifications and unread count
    final allNotifications = notificationState.allNotifications;
    final totalUnreadCount = notificationState.unreadCount;

    // Load more data function
    void loadMoreData() {
      if (!notificationState.isLoadingMore && notificationState.hasMoreData) {
        ref.read(notificationProvider.notifier).loadMore();
      }
    }

    // Handle manual reconnect
    void handleManualReconnect() async {
      if (websocketState.isConnecting || isReconnecting.value) return;

      isReconnecting.value = true;
      try {
        final result = await getAccessTokenUseCase.execute();
        result.fold(
          (failure) {
            isReconnecting.value = false;
          },
          (token) async {
            await ref
                .read(notificationWebSocketProvider.notifier)
                .reconnect(token);
            isReconnecting.value = false;
          },
        );
      } catch (e) {
        isReconnecting.value = false;
      }
    }

    // Auto-reconnect effect
    useEffect(
      () {
        final debouncer = Debouncer();
        bool isDisposed = false;

        if (websocketState.hasError &&
            !websocketState.isConnected &&
            !websocketState.isConnecting) {
          debouncer.debounce(
            duration: const Duration(seconds: 5),
            onDebounce: () {
              if (!isDisposed) handleManualReconnect();
            },
          );
        }

        return () {
          isDisposed = true;
          debouncer.cancel();
        };
      },
      [
        websocketState.hasError,
        websocketState.isConnected,
        websocketState.isConnecting,
      ],
    );

    // Scroll listener
    void onScroll() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        loadMoreData();
      }
    }

    // Handle refresh
    Future<void> handleRefresh() async {
      ref.read(notificationProvider.notifier).refresh();
    }

    // Mark all as read
    void markAllAsRead() {
      ref.read(notificationProvider.notifier).markAllAsRead();
    }

    // Mark single notification as read
    void markAsRead(int notificationId) {
      ref.read(notificationProvider.notifier).markAsRead(notificationId);
    }

    // Add scroll listener
    useEffect(() {
      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    // Load notifications on first build
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (notificationState.apiNotifications.isEmpty &&
            !notificationState.isLoading) {
          ref.read(notificationProvider.notifier).loadNotifications();
        }
      });
      return null;
    }, []);

    return SmartScaffold(
      appBarType: AppBarType.standard,
      showBackButton: true,
      body: SafeArea(
        child: Column(
          children: [
            // Connection status bar only (no error details)
            NotificationConnectionStatusWidget(
              webSocketState: websocketState,
              isTablet: isTablet,
              onReconnect: handleManualReconnect,
              isReconnecting: isReconnecting.value,
            ),

            // Main content
            Expanded(
              child: RefreshIndicator(
                onRefresh: handleRefresh,
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // View All Notifications Header
                    if (allNotifications.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(
                            isTablet ? 24 : 16,
                            isTablet ? 16 : 12,
                            isTablet ? 24 : 16,
                            isTablet ? 8 : 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: colorScheme.primary,
                                size: isTablet ? 24 : 20,
                              ),
                              SizedBox(width: isTablet ? 8 : 6),
                              Text(
                                'Tất cả thông báo',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              if (totalUnreadCount > 0) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 12 : 8,
                                    vertical: isTablet ? 6 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '$totalUnreadCount chưa đọc',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                // Mark all as read button
                                InkWell(
                                  onTap: markAllAsRead,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 12 : 8,
                                      vertical: isTablet ? 6 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.done_all,
                                          color: colorScheme.onPrimary,
                                          size: isTablet ? 16 : 14,
                                        ),
                                        SizedBox(width: isTablet ? 6 : 4),
                                        Text(
                                          'Đọc tất cả',
                                          style: TextStyle(
                                            fontSize: isTablet ? 12 : 10,
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    // Loading state for initial load
                    if (notificationState.isLoading && allNotifications.isEmpty)
                      SliverToBoxAdapter(
                        child: NotificationsSkeleton(
                          isTablet: isTablet,
                          colorScheme: colorScheme,
                        ),
                      ),

                    // Empty state
                    if (!notificationState.isLoading &&
                        allNotifications.isEmpty)
                      SliverToBoxAdapter(
                        child: EmptyNotificationsState(
                          isTablet: isTablet,
                          colorScheme: colorScheme,
                        ),
                      ),

                    // Notifications List
                    if (allNotifications.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 16,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < allNotifications.length) {
                                final notification = allNotifications[index];

                                if (notification is NotificationSocket) {
                                  return WebSocketNotificationItem(
                                    notification: notification,
                                    isTablet: isTablet,
                                    colorScheme: colorScheme,
                                    onTap: () => markAsRead(notification.id),
                                  );
                                } else if (notification
                                    is entities.Notification) {
                                  return NotificationItem(
                                    notification: notification,
                                    isTablet: isTablet,
                                    colorScheme: colorScheme,
                                    onTap: () => markAsRead(notification.id),
                                  );
                                }
                              } else if (notificationState.isLoadingMore) {
                                return LoadingItem(
                                  isTablet: isTablet,
                                  colorScheme: colorScheme,
                                );
                              } else if (!notificationState.hasMoreData) {
                                return EndOfListItem(
                                  isTablet: isTablet,
                                  colorScheme: colorScheme,
                                );
                              }
                              return null;
                            },
                            childCount:
                                allNotifications.length +
                                (notificationState.isLoadingMore ? 1 : 0) +
                                (!notificationState.hasMoreData ? 1 : 0),
                          ),
                        ),
                      ),

                    // Bottom padding
                    SliverToBoxAdapter(
                      child: SizedBox(height: isTablet ? 24 : 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyNotificationsState extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const EmptyNotificationsState({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 48 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: isTablet ? 80 : 64,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Chưa có thông báo nào',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Các thông báo sẽ xuất hiện ở đây',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
