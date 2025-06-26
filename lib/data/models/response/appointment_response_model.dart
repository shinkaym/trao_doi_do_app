import 'package:trao_doi_do_app/data/models/appointment_model.dart';
import 'package:trao_doi_do_app/domain/entities/response/appointment_response.dart';

class AppointmentsResponseModel {
  final List<AppointmentModel> appointments;
  final int totalPage;

  const AppointmentsResponseModel({
    required this.appointments,
    required this.totalPage,
  });

  factory AppointmentsResponseModel.fromJson(Map<String, dynamic> json) {
    return AppointmentsResponseModel(
      appointments: (json['appointments'] as List<dynamic>? ?? [])
          .map((appointment) => AppointmentModel.fromJson(
                appointment as Map<String, dynamic>,
              ))
          .toList(),
      totalPage: json['totalPage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointments': appointments.map((appointment) => appointment.toJson()).toList(),
      'totalPage': totalPage,
    };
  }

  AppointmentsResponse toEntity() {
    return AppointmentsResponse(
      appointments: appointments.map((appointment) => appointment.toEntity()).toList(),
      totalPage: totalPage,
    );
  }

  factory AppointmentsResponseModel.fromEntity(AppointmentsResponse entity) {
    return AppointmentsResponseModel(
      appointments: entity.appointments
          .map((appointment) => AppointmentModel.fromEntity(appointment))
          .toList(),
      totalPage: entity.totalPage,
    );
  }
}

class AppointmentDetailResponseModel {
  final AppointmentModel appointment;

  const AppointmentDetailResponseModel({required this.appointment});

  factory AppointmentDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return AppointmentDetailResponseModel(
      appointment: AppointmentModel.fromJson(
        json['appointment'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment': appointment.toJson(),
    };
  }

  AppointmentDetailResponse toEntity() {
    return AppointmentDetailResponse(
      appointment: appointment.toEntity(),
    );
  }

  factory AppointmentDetailResponseModel.fromEntity(AppointmentDetailResponse entity) {
    return AppointmentDetailResponseModel(
      appointment: AppointmentModel.fromEntity(entity.appointment),
    );
  }
}