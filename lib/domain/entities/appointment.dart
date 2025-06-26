import 'package:equatable/equatable.dart';

class AppointmentItem extends Equatable {
  final int actualQuantity;
  final int appointmentID;
  final String categoryName;
  final int id;
  final int itemID;
  final String itemImage;
  final String itemName;
  final int missingQuantity;

  const AppointmentItem({
    required this.actualQuantity,
    required this.appointmentID,
    required this.categoryName,
    required this.id,
    required this.itemID,
    required this.itemImage,
    required this.itemName,
    required this.missingQuantity,
  });

  @override
  List<Object?> get props => [
    actualQuantity,
    appointmentID,
    categoryName,
    id,
    itemID,
    itemImage,
    itemName,
    missingQuantity,
  ];
}

class Appointment extends Equatable {
  final List<AppointmentItem> appointmentItems;
  final String createdAt;
  final String endTime;
  final int id;
  final String startTime;
  final int status;
  final int userID;
  final String userName;

  const Appointment({
    required this.appointmentItems,
    required this.createdAt,
    required this.endTime,
    required this.id,
    required this.startTime,
    required this.status,
    required this.userID,
    required this.userName,
  });

  @override
  List<Object?> get props => [
    appointmentItems,
    createdAt,
    endTime,
    id,
    startTime,
    status,
    userID,
    userName,
  ];
}

class AppointmentsResult {
  final List<Appointment> appointments;
  final int totalPage;

  const AppointmentsResult({
    required this.appointments,
    required this.totalPage,
  });
}

class UpdateAppointment extends Equatable {
  final String? endTime;
  final String? startTime;
  final int? status;

  const UpdateAppointment({this.endTime, this.startTime, this.status});

  @override
  List<Object?> get props => [endTime, startTime, status];
}
