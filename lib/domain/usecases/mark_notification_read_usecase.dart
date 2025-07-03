import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<Either<Failure, void>> call(int notificationID) async {
    if (notificationID <= 0) {
      return const Left(ValidationFailure('ID thông báo không hợp lệ'));
    }

    return await _repository.markNotificationAsRead(notificationID);
  }
}
