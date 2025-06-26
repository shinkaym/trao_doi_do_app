import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/repositories/appointment_repository.dart';

class GetAppointmentDetailUseCase {
  final AppointmentRepository _repository;

  GetAppointmentDetailUseCase(this._repository);

  Future<Either<Failure, Appointment>> call(int appointmentID) async {
    if (appointmentID <= 0) {
      return const Left(ValidationFailure('Appointment ID không hợp lệ'));
    }

    return await _repository.getAppointmentDetail(appointmentID);
  }
}
