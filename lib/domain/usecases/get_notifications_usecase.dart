import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/notification_response.dart';
import 'package:trao_doi_do_app/domain/repositories/notification_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/params/notification_query.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<Either<Failure, NotificationsResponse>> call(
    NotificationQuery query,
  ) async {
    return await _repository.getNotifications(query);
  }
}
