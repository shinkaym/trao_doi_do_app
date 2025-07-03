import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/modules/presentation_module.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/notification.dart' as entities;
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointment_detail_dialog.dart';

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
              // Notification Icon with gradient and shadow (similar to WebSocket)
              Container(
                width: isTablet ? 40 : 36,
                height: isTablet ? 40 : 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getNotificationColor(notification.type),
                      _getNotificationColor(notification.type).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getNotificationColor(
                        notification.type,
                      ).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: Colors.white,
                    size: isTablet ? 20 : 18,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender name (without real-time badge)
                    Text(
                      notification.senderName.isNotEmpty == true
                          ? notification.senderName
                          : 'Hệ thống',

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
                      TimeUtils.formatTimeAgo(
                        DateTime.parse(notification.createdAt),
                      ),
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
        return Icons.settings;
      case 'normal':
        return Icons.info;
      default:
        return Icons.info;
    }
  }
}
