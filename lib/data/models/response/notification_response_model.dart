import 'package:trao_doi_do_app/domain/entities/response/notification_response.dart';
import '../notification_model.dart';

class NotificationsResponseModel {
  final List<NotificationModel> notifications;
  final int totalPage;
  final int unreadCount;

  const NotificationsResponseModel({
    required this.notifications,
    required this.totalPage,
    required this.unreadCount,
  });

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseModel(
      notifications:
          (json['notifications'] as List<dynamic>)
              .map(
                (notification) => NotificationModel.fromJson(
                  notification as Map<String, dynamic>,
                ),
              )
              .toList(),
      totalPage: json['totalPage'] as int,
      unreadCount: json['unreadCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications':
          notifications.map((notification) => notification.toJson()).toList(),
      'totalPage': totalPage,
      'unreadCount': unreadCount,
    };
  }

  NotificationsResponse toEntity() {
    return NotificationsResponse(
      notifications:
          notifications.map((notification) => notification.toEntity()).toList(),
      totalPage: totalPage,
      unreadCount: unreadCount,
    );
  }

  factory NotificationsResponseModel.fromEntity(NotificationsResponse entity) {
    return NotificationsResponseModel(
      notifications:
          entity.notifications
              .map((notification) => NotificationModel.fromEntity(notification))
              .toList(),
      totalPage: entity.totalPage,
      unreadCount: entity.unreadCount,
    );
  }
}
