import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';

class AppointmentsResponse extends Equatable {
  final List<Appointment> appointments;
  final int totalPage;

  const AppointmentsResponse({
    required this.appointments,
    required this.totalPage,
  });

  @override
  List<Object?> get props => [appointments, totalPage];
}

class AppointmentDetailResponse extends Equatable {
  final Appointment appointment;

  const AppointmentDetailResponse({required this.appointment});

  @override
  List<Object?> get props => [appointment];
}