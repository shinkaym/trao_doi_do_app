import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/appointment_remote_datasource.dart';
import 'package:trao_doi_do_app/data/models/appointment_model.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/repositories/appointment_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/params/appointment_query.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource _remoteDataSource;

  AppointmentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AppointmentsResult>> getAppointments(
    AppointmentQuery query,
  ) async {
    return handleRepositoryCall(() async {
      final response = await _remoteDataSource.getAppointments(query);
      return AppointmentsResult(
        appointments: response.appointments.map((e) => e.toEntity()).toList(),
        totalPage: response.totalPage,
      );
    }, 'Lỗi khi tải danh sách lịch hẹn');
  }

  @override
  Future<Either<Failure, Appointment>> getAppointmentDetail(
    int appointmentID,
  ) async {
    return handleRepositoryCall(() async {
      final response = await _remoteDataSource.getAppointmentDetail(
        appointmentID,
      );
      return response.toEntity();
    }, 'Lỗi khi tải chi tiết lịch hẹn');
  }

  @override
  Future<Either<Failure, String>> updateAppointment(
    int appointmentID,
    UpdateAppointment updateAppointment,
  ) async {
    return handleRepositoryCall<String>(() async {
      final updateAppointmentModel = UpdateAppointmentModel.fromEntity(
        updateAppointment,
      );
      final result = await _remoteDataSource.updateAppointment(
        appointmentID,
        updateAppointmentModel,
      );
      return result;
    }, 'Lỗi cập nhật lịch hẹn');
  }
}
