import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/notification_socket.dart';

class WebSocketNotificationItem extends StatelessWidget {
  final NotificationSocket notification;
  final bool isTablet;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const WebSocketNotificationItem({
    super.key,
    required this.notification,
    required this.isTablet,
    required this.colorScheme,
    required this.onTap,
  });

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
              // Real-time indicator
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
                    // Sender name with real-time badge
                    Row(
                      children: [
                        Text(
                          notification.senderName ?? 'Hệ thống',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TRỰC TIẾP',
                            style: TextStyle(
                              fontSize: isTablet ? 10 : 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
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
                      TimeUtils.formatTimeAgo(notification.createdAt),
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

  void _handleNotificationTap(
    BuildContext context,
    NotificationSocket notification,
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
        // Handle appointment detail
        break;
      default:
        break;
    }
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
