import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointment_detail_dialog.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';
import 'package:trao_doi_do_app/domain/entities/notification.dart' as entities;

class NotificationScreen extends HookConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final notificationState = ref.watch(notificationProvider);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    // Load more data function
    void loadMoreData() {
      if (!notificationState.isLoadingMore && notificationState.hasMoreData) {
        ref.read(notificationProvider.notifier).loadMore();
      }
    }

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

    // Load initial data
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (notificationState.notifications.isEmpty &&
            !notificationState.isLoading) {
          ref
              .read(notificationProvider.notifier)
              .loadNotifications(refresh: true);
        }
      });
      return null;
    }, []);

    // Show success message
    useEffect(() {
      if (notificationState.successMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notificationState.successMessage!),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(notificationProvider.notifier).clearSuccessMessage();
        });
      }
      return null;
    }, [notificationState.successMessage]);

    return SmartScaffold(
      appBarType: AppBarType.standard,
      showBackButton: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: handleRefresh,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Error handling
              if (notificationState.failure != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(isTablet ? 24 : 16),
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.onErrorContainer,
                          size: isTablet ? 24 : 20,
                        ),
                        SizedBox(width: isTablet ? 12 : 8),
                        Expanded(
                          child: Text(
                            'Có lỗi xảy ra khi tải thông báo. Vui lòng thử lại.',
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // View All Notifications Header
              if (notificationState.notifications.isNotEmpty)
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
                        if (notificationState.unreadCount > 0) ...[
                          Text(
                            '${notificationState.unreadCount} chưa đọc',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
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

              // Mark All Read Button (Alternative placement - when no unread notifications)
              if (notificationState.notifications.isNotEmpty &&
                  notificationState.unreadCount == 0)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      isTablet ? 24 : 16,
                      0,
                      isTablet ? 24 : 16,
                      isTablet ? 8 : 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.primary.withOpacity(0.7),
                          size: isTablet ? 20 : 16,
                        ),
                        SizedBox(width: isTablet ? 8 : 6),
                        Text(
                          'Tất cả thông báo đã được đọc',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: colorScheme.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Loading state for initial load
              if (notificationState.isLoading &&
                  notificationState.notifications.isEmpty)
                SliverToBoxAdapter(
                  child: NotificationsSkeleton(
                    isTablet: isTablet,
                    colorScheme: colorScheme,
                  ),
                ),

              // Empty state
              if (!notificationState.isLoading &&
                  notificationState.notifications.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyNotificationsState(
                    isTablet: isTablet,
                    colorScheme: colorScheme,
                  ),
                ),

              // Notifications List
              if (notificationState.notifications.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < notificationState.notifications.length) {
                          final notification =
                              notificationState.notifications[index];
                          return NotificationItem(
                            notification: notification,
                            isTablet: isTablet,
                            colorScheme: colorScheme,
                            onTap: () => markAsRead(notification.id),
                          );
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
                          notificationState.notifications.length +
                          (notificationState.isLoadingMore ? 1 : 0) +
                          (!notificationState.hasMoreData ? 1 : 0),
                    ),
                  ),
                ),

              // Bottom padding
              SliverToBoxAdapter(child: SizedBox(height: isTablet ? 24 : 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final entities.Notification notification;
  final bool isTablet;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.isTablet,
    required this.colorScheme,
    required this.onTap,
  });

  void _showAppointmentDetail(BuildContext context, int appointmentId) {
    // Sử dụng Provider để load appointment detail
    final ref = ProviderScope.containerOf(context);
    final appointmentDetailNotifier = ref.read(
      appointmentDetailProvider(appointmentId).notifier,
    );

    // Load appointment detail
    appointmentDetailNotifier.loadAppointmentDetail(appointmentId);

    // Hiển thị dialog
    showDialog(
      context: context,
      builder:
          (context) => Consumer(
            builder: (context, ref, child) {
              final appointmentState = ref.watch(
                appointmentDetailProvider(appointmentId),
              );

              if (appointmentState.isLoading) {
                return Dialog(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Đang tải thông tin cuộc hẹn...',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (appointmentState.failure != null) {
                return AlertDialog(
                  title: const Text('Lỗi'),
                  content: Text(appointmentState.failure!.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đóng'),
                    ),
                  ],
                );
              }

              if (appointmentState.appointmentDetail != null) {
                return AppointmentDetailDialog(
                  appointment: appointmentState.appointmentDetail!,
                  isTablet: isTablet,
                  theme: Theme.of(context),
                  colorScheme: colorScheme,
                );
              }

              return const SizedBox.shrink();
            },
          ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    entities.Notification notification,
  ) {
    switch (notification.targetType.toLowerCase()) {
      case 'interest':
        context.pushNamed(
          RouteNames.interestChat,
          pathParameters: {'interestId': notification.targetID.toString()},
        );
        break;

      case 'post':
        context.pushNamed(
          RouteNames.postDetailById,
          pathParameters: {'postId': notification.targetID.toString()},
        );
        break;

      case 'appointment':
        _showAppointmentDetail(context, notification.targetID);
        break;

      default:
        // Trường hợp không xác định, có thể log hoặc hiển thị thông báo
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color:
            notification.isRead
                ? colorScheme.surface
                : colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              notification.isRead
                  ? colorScheme.outline.withOpacity(0.2)
                  : colorScheme.primary.withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          onTap();
          _handleNotificationTap(context, notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                width: isTablet ? 40 : 36,
                height: isTablet ? 40 : 36,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                  size: isTablet ? 20 : 18,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender name
                    Text(
                      notification.senderName,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    // Content
                    Text(
                      notification.content,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: colorScheme.onSurface,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    // Time
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Read status indicator
              if (!notification.isRead)
                Container(
                  width: isTablet ? 10 : 8,
                  height: isTablet ? 10 : 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'system':
        return Colors.orange.shade400;
      case 'normal':
        return Colors.blue.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'system':
        return Icons.notifications;
      case 'normal':
        return Icons.info;
      default:
        return Icons.info;
    }
  }

  String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Vừa xong';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return createdAt;
    }
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

class NotificationsSkeleton extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const NotificationsSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      child: Column(
        children: List.generate(6, (index) => _buildSkeletonItem()),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 40 : 36,
            height: isTablet ? 40 : 36,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: isTablet ? 14 : 12,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Container(
                  width: double.infinity,
                  height: isTablet ? 14 : 12,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Container(
                  width: 150,
                  height: isTablet ? 14 : 12,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Container(
                  width: 100,
                  height: isTablet ? 12 : 10,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingItem extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const LoadingItem({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class EndOfListItem extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const EndOfListItem({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: isTablet ? 40 : 32,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Đã hiển thị tất cả thông báo',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
