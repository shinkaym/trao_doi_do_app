import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/repositories/appointment_repository.dart';

class UpdateAppointmentUseCase {
  final AppointmentRepository _repository;

  UpdateAppointmentUseCase(this._repository);

  Future<Either<Failure, String>> call(
    int appointmentID,
    UpdateAppointment updateAppointment,
  ) async {
    // Validation
    if (appointmentID <= 0) {
      return const Left(ValidationFailure('ID lịch hẹn không hợp lệ'));
    }

    // Validate status if provided
    if (updateAppointment.status != null) {
      if (updateAppointment.status! < 0 || updateAppointment.status! > 4) {
        return const Left(ValidationFailure('Trạng thái không hợp lệ'));
      }
    }

    // Validate times if provided
    if (updateAppointment.startTime != null &&
        updateAppointment.endTime != null) {
      try {
        final startTime = DateTime.parse(updateAppointment.startTime!);
        final endTime = DateTime.parse(updateAppointment.endTime!);

        if (endTime.isBefore(startTime)) {
          return const Left(
            ValidationFailure('Thời gian kết thúc phải sau thời gian bắt đầu'),
          );
        }
      } catch (e) {
        return const Left(
          ValidationFailure('Định dạng thời gian không hợp lệ'),
        );
      }
    }

    return await _repository.updateAppointment(
      appointmentID,
      updateAppointment,
    );
  }
}
