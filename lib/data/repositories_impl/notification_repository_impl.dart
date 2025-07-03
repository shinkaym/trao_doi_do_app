import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/notification_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/response/notification_response.dart';
import 'package:trao_doi_do_app/domain/repositories/notification_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/params/notification_query.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications(
    NotificationQuery query,
  ) async {
    return handleRepositoryCall<NotificationsResponse>(() async {
      final remoteResponse = await _remoteDataSource.getNotifications(query);
      final notificationsEntity = remoteResponse.toEntity();
      return notificationsEntity;
    }, 'Lỗi tải danh sách thông báo');
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(
    int notificationID,
  ) async {
    return handleRepositoryCall<void>(() async {
      await _remoteDataSource.markNotificationAsRead(notificationID);
    }, 'Lỗi đánh dấu thông báo đã đọc');
  }

  @override
  Future<Either<Failure, void>> markAllNotificationsAsRead() async {
    return handleRepositoryCall<void>(() async {
      await _remoteDataSource.markAllNotificationsAsRead();
    }, 'Lỗi đánh dấu tất cả thông báo đã đọc');
  }
}
