import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

// Model cho notification
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'system', 'item', 'post', 'trade', 'message'
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? targetId; // ID của item/post/trade để navigate
  final String? deepLink; // Deep link nội bộ app
  final String? webUrl; // URL website để mở bằng URL launcher
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.targetId,
    this.deepLink,
    this.webUrl,
    this.metadata,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    String? targetId,
    String? deepLink,
    String? webUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      targetId: targetId ?? this.targetId,
      deepLink: deepLink ?? this.deepLink,
      webUrl: webUrl ?? this.webUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

// State để quản lý notifications
@immutable
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notification Provider
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Giả lập data thông báo
      await Future.delayed(const Duration(seconds: 1));

      final notifications = [
        NotificationModel(
          id: '1',
          title: 'Có người quan tâm đến món đồ của bạn',
          message: 'Nguyễn Văn B đã thích chiếc áo khoác bạn đăng bán',
          type: 'item',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          imageUrl: 'https://dummyimage.com/60x60/000/fff',
          targetId: 'item_123',
          deepLink: '/item-detail/item_123',
        ),
        NotificationModel(
          id: '2',
          title: 'Tin nhắn mới',
          message: 'Bạn có tin nhắn mới từ Trần Thị C về việc trao đổi',
          type: 'message',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
          targetId: 'chat_456',
          deepLink: '/chat/chat_456',
        ),
        NotificationModel(
          id: '3',
          title: 'Giao dịch thành công',
          message: 'Bạn đã hoàn thành giao dịch trao đổi với Lê Văn D',
          type: 'trade',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
          targetId: 'trade_789',
          deepLink: '/trade-detail/trade_789',
        ),
        NotificationModel(
          id: '4',
          title: 'Bài đăng mới phù hợp',
          message: 'Có bài đăng mới về "iPhone 13" phù hợp với nhu cầu của bạn',
          type: 'post',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          imageUrl: 'https://dummyimage.com/60x60/000/fff',
          targetId: 'post_101',
          deepLink: '/post-detail/post_101',
        ),
        NotificationModel(
          id: '5',
          title: 'Cập nhật ứng dụng v2.1.0',
          message:
              'Ứng dụng đã được cập nhật với nhiều tính năng mới và cải thiện hiệu suất',
          type: 'system',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
          webUrl: 'https://flutter.dev',
        ),
        NotificationModel(
          id: '6',
          title: 'Hướng dẫn sử dụng tính năng mới',
          message: 'Tìm hiểu cách sử dụng tính năng trao đổi thông minh mới',
          type: 'system',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          isRead: false,
          webUrl: 'https://flutter.dev',
        ),
      ];

      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi tải thông báo: $e',
      );
    }
  }

  void markAsRead(String notificationId) {
    final updatedNotifications =
        state.notifications.map((notification) {
          if (notification.id == notificationId && !notification.isRead) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

    state = state.copyWith(notifications: updatedNotifications);

    // Gửi API để đánh dấu đã đọc
    // NotificationService.markAsRead(notificationId);
  }

  void markAllAsRead() {
    final updatedNotifications =
        state.notifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList();

    state = state.copyWith(notifications: updatedNotifications);
  }
}

// Providers
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
      (ref) => NotificationNotifier(),
    );

// Computed providers
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider).notifications;
  return notifications.where((n) => !n.isRead).length;
});

final notificationsByTypeProvider =
    Provider.family<List<NotificationModel>, String>((ref, type) {
      final notifications = ref.watch(notificationProvider).notifications;
      return notifications.where((n) => n.type == type).toList();
    });

final filteredNotificationsProvider =
    Provider.family<List<NotificationModel>, String>((ref, filter) {
      final notifications = ref.watch(notificationProvider).notifications;
      switch (filter) {
        case 'unread':
          return notifications.where((n) => !n.isRead).toList();
        case 'read':
          return notifications.where((n) => n.isRead).toList();
        default:
          return notifications;
      }
    });

class NotificationScreen extends HookConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    final tabController = useTabController(initialLength: 4);

    final notificationState = ref.watch(notificationProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    useEffect(() {
      // Load notifications when screen is first built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notificationProvider.notifier).loadNotifications();
      });
      return null;
    }, []);

    // Listen to error state
    ref.listen<NotificationState>(notificationProvider, (previous, next) {
      if (next.error != null) {
        context.showErrorSnackBar(next.error!);
      }
    });

    Future<void> onRefresh() async {
      await ref.read(notificationProvider.notifier).loadNotifications();
    }

    void onMarkAllAsRead() {
      ref.read(notificationProvider.notifier).markAllAsRead();
      context.showSuccessSnackBar('Đã đánh dấu tất cả thông báo là đã đọc');
    }

    return SmartScaffold(
      title: 'Thông báo',
      appBarType: AppBarType.standard,
      showBackButton: true,
      showNotification: false,
      appBarActions: [
        if (unreadCount > 0)
          TextButton.icon(
            onPressed: onMarkAllAsRead,
            icon: const Icon(Icons.mark_email_read_outlined, size: 18),
            label: const Text(
              'Đọc tất cả',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            style: TextButton.styleFrom(foregroundColor: colorScheme.onPrimary),
          ),
      ],
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelColor: colorScheme.primary,
              unselectedLabelColor: theme.hintColor,
              indicatorColor: colorScheme.primary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tất cả'),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Giao dịch'),
                const Tab(text: 'Tin nhắn'),
                const Tab(text: 'Hệ thống'),
              ],
            ),
          ),

          // Content
          Expanded(
            child:
                notificationState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: tabController,
                      children: [
                        // Tất cả thông báo
                        NotificationListTab(
                          notifications: ref.watch(
                            filteredNotificationsProvider('all'),
                          ),
                          onRefresh: onRefresh,
                        ),
                        // Giao dịch
                        NotificationListTab(
                          notifications: [
                            ...ref.watch(notificationsByTypeProvider('trade')),
                            ...ref.watch(notificationsByTypeProvider('item')),
                          ],
                          onRefresh: onRefresh,
                        ),
                        // Tin nhắn
                        NotificationListTab(
                          notifications: ref.watch(
                            notificationsByTypeProvider('message'),
                          ),
                          onRefresh: onRefresh,
                        ),
                        // Hệ thống
                        NotificationListTab(
                          notifications: ref.watch(
                            notificationsByTypeProvider('system'),
                          ),
                          onRefresh: onRefresh,
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

class NotificationListTab extends HookConsumerWidget {
  final List<NotificationModel> notifications;
  final VoidCallback onRefresh;

  const NotificationListTab({
    super.key,
    required this.notifications,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Không có thông báo nào',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        itemCount: notifications.length,
        separatorBuilder:
            (context, index) => SizedBox(height: isTablet ? 12 : 8),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItem(notification: notification);
        },
      ),
    );
  }
}

class NotificationItem extends HookConsumerWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification})
   ;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    Future<void> openUrl(String url) async {
      try {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (context.mounted) {
            context.showErrorSnackBar('Không thể mở liên kết: $url');
          }
        }
      } catch (e) {
        if (context.mounted) {
          context.showErrorSnackBar('Lỗi khi mở liên kết: $e');
        }
      }
    }

    void showSystemNotificationDialog() {
      context.showInfoDialog(
        title: notification.title,
        content: notification.message,
        buttonText: 'Đóng',
        icon: Icons.info_outline,
      );
    }

    void handleNotificationTap() async {
      // Đánh dấu đã đọc
      ref.read(notificationProvider.notifier).markAsRead(notification.id);

      // Điều hướng dựa trên loại thông báo
      if (notification.webUrl != null && notification.webUrl!.isNotEmpty) {
        await openUrl(notification.webUrl!);
      } else if (notification.deepLink != null &&
          notification.deepLink!.isNotEmpty) {
        context.push(notification.deepLink!);
      } else {
        // Fallback navigation dựa trên type
        switch (notification.type) {
          case 'item':
            if (notification.targetId != null) {
              context.pushNamed(
                'item-detail',
                pathParameters: {'id': notification.targetId!},
              );
            }
            break;
          case 'post':
            if (notification.targetId != null) {
              context.pushNamed(
                'post-detail',
                pathParameters: {'slug': notification.targetId!},
              );
            }
            break;
          case 'trade':
            if (notification.targetId != null) {
              context.pushNamed(
                'trade-detail',
                pathParameters: {'id': notification.targetId!},
              );
            }
            break;
          case 'message':
            if (notification.targetId != null) {
              context.pushNamed(
                'chat',
                pathParameters: {'id': notification.targetId!},
              );
            }
            break;
          case 'system':
            showSystemNotificationDialog();
            break;
        }
      }
    }

    IconData getNotificationIcon(String type) {
      switch (type) {
        case 'item':
          return Icons.shopping_bag_outlined;
        case 'post':
          return Icons.article_outlined;
        case 'trade':
          return Icons.swap_horiz;
        case 'message':
          return Icons.message_outlined;
        case 'system':
          return Icons.info_outline;
        default:
          return Icons.notifications_outlined;
      }
    }

    Color getNotificationColor(String type) {
      switch (type) {
        case 'item':
          return Colors.blue;
        case 'post':
          return Colors.green;
        case 'trade':
          return Colors.orange;
        case 'message':
          return colorScheme.primary;
        case 'system':
          return Colors.grey;
        default:
          return colorScheme.primary;
      }
    }

    return Card(
      elevation: notification.isRead ? 1 : 3,
      color:
          notification.isRead
              ? colorScheme.surface
              : colorScheme.primary.withOpacity(0.01),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            notification.isRead
                ? BorderSide.none
                : BorderSide(
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
      ),
      child: InkWell(
        onTap: handleNotificationTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon hoặc Avatar
              Container(
                width: isTablet ? 50 : 44,
                height: isTablet ? 50 : 44,
                decoration: BoxDecoration(
                  color: getNotificationColor(
                    notification.type,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child:
                    notification.imageUrl != null &&
                            notification.imageUrl!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            notification.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  getNotificationIcon(notification.type),
                                  color: getNotificationColor(
                                    notification.type,
                                  ),
                                  size: isTablet ? 26 : 22,
                                ),
                          ),
                        )
                        : Icon(
                          getNotificationIcon(notification.type),
                          color: getNotificationColor(notification.type),
                          size: isTablet ? 26 : 22,
                        ),
              ),
              SizedBox(width: isTablet ? 16 : 12),

              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 15,
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                              color:
                                  notification.isRead
                                      ? theme.textTheme.bodyLarge?.color
                                      : colorScheme.primary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        color: theme.hintColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    Text(
                      TimeUtils.formatTimeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color: theme.hintColor.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: theme.hintColor.withOpacity(0.5),
                size: isTablet ? 24 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
