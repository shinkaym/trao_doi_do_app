import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/appointment_response_model.dart';
import 'package:trao_doi_do_app/data/models/appointment_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/appointment_query.dart';

abstract class AppointmentRemoteDataSource {
  Future<AppointmentsResponseModel> getAppointments(AppointmentQuery query);
  Future<AppointmentModel> getAppointmentDetail(int appointmentID);
  Future<String> updateAppointment(
    int appointmentID,
    UpdateAppointmentModel updateAppointment,
  );
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final DioClient _dioClient;

  AppointmentRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AppointmentsResponseModel> getAppointments(
    AppointmentQuery query,
  ) async {
    final response = await _dioClient.get(
      ApiConstants.clientAppointments,
      queryParameters: query.toQueryParams(),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) =>
          AppointmentsResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<AppointmentModel> getAppointmentDetail(int appointmentID) async {
    final response = await _dioClient.get(
      '${ApiConstants.appointments}/$appointmentID',
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) =>
          AppointmentDetailResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!.appointment;
  }

  @override
  Future<String> updateAppointment(
    int appointmentID,
    UpdateAppointmentModel updateAppointment,
  ) async {
    final response = await _dioClient.patch(
      '${ApiConstants.appointments}/$appointmentID',
      data: updateAppointment.toJson(),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (data) => data.toString(),
    );

    return result.data!;
  }
}
