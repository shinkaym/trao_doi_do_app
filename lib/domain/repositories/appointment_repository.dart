import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/usecases/params/appointment_query.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, AppointmentsResult>> getAppointments(
    AppointmentQuery query,
  );

  Future<Either<Failure, Appointment>> getAppointmentDetail(int appointmentID);
  Future<Either<Failure, String>> updateAppointment(
    int appointmentID,
    UpdateAppointment updateAppointment,
  );
}
