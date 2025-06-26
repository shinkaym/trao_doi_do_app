import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/repositories/appointment_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/params/appointment_query.dart';

class GetAppointmentsUseCase {
  final AppointmentRepository _repository;

  GetAppointmentsUseCase(this._repository);

  Future<Either<Failure, AppointmentsResult>> call(
    AppointmentQuery query,
  ) async {
    return await _repository.getAppointments(query);
  }
}
