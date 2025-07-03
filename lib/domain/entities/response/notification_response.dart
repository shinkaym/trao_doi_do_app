import 'package:equatable/equatable.dart';
import '../notification.dart';

class NotificationsResponse extends Equatable {
  final List<Notification> notifications;
  final int totalPage;
  final int unreadCount;

  const NotificationsResponse({
    required this.notifications,
    required this.totalPage,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, totalPage, unreadCount];
}
