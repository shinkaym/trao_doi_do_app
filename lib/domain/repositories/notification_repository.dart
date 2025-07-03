import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/notification_response.dart';
import 'package:trao_doi_do_app/domain/usecases/params/notification_query.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationsResponse>> getNotifications(
    NotificationQuery query,
  );
  Future<Either<Failure, void>> markNotificationAsRead(int notificationID);
  Future<Either<Failure, void>> markAllNotificationsAsRead();
}
