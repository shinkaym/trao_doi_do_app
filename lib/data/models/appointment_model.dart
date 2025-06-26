import 'package:trao_doi_do_app/domain/entities/appointment.dart';

class AppointmentItemModel {
  final int actualQuantity;
  final int appointmentID;
  final String categoryName;
  final int id;
  final int itemID;
  final String itemImage;
  final String itemName;
  final int missingQuantity;

  const AppointmentItemModel({
    required this.actualQuantity,
    required this.appointmentID,
    required this.categoryName,
    required this.id,
    required this.itemID,
    required this.itemImage,
    required this.itemName,
    required this.missingQuantity,
  });

  factory AppointmentItemModel.fromJson(Map<String, dynamic> json) {
    return AppointmentItemModel(
      actualQuantity: json['actualQuantity'] ?? 0,
      appointmentID: json['appointmentID'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      id: json['id'] ?? 0,
      itemID: json['itemID'] ?? 0,
      itemImage: json['itemImage'] ?? '',
      itemName: json['itemName'] ?? '',
      missingQuantity: json['missingQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actualQuantity': actualQuantity,
      'appointmentID': appointmentID,
      'categoryName': categoryName,
      'id': id,
      'itemID': itemID,
      'itemImage': itemImage,
      'itemName': itemName,
      'missingQuantity': missingQuantity,
    };
  }

  AppointmentItem toEntity() {
    return AppointmentItem(
      actualQuantity: actualQuantity,
      appointmentID: appointmentID,
      categoryName: categoryName,
      id: id,
      itemID: itemID,
      itemImage: itemImage,
      itemName: itemName,
      missingQuantity: missingQuantity,
    );
  }

  factory AppointmentItemModel.fromEntity(AppointmentItem entity) {
    return AppointmentItemModel(
      actualQuantity: entity.actualQuantity,
      appointmentID: entity.appointmentID,
      categoryName: entity.categoryName,
      id: entity.id,
      itemID: entity.itemID,
      itemImage: entity.itemImage,
      itemName: entity.itemName,
      missingQuantity: entity.missingQuantity,
    );
  }
}

class AppointmentModel {
  final List<AppointmentItemModel> appointmentItems;
  final String createdAt;
  final String endTime;
  final int id;
  final String startTime;
  final int status;
  final int userID;
  final String userName;

  const AppointmentModel({
    required this.appointmentItems,
    required this.createdAt,
    required this.endTime,
    required this.id,
    required this.startTime,
    required this.status,
    required this.userID,
    required this.userName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointmentItems:
          (json['appointmentItems'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    AppointmentItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      createdAt: json['createdAt'] ?? '',
      endTime: json['endTime'] ?? '',
      id: json['id'] ?? 0,
      startTime: json['startTime'] ?? '',
      status: json['status'] ?? 0,
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentItems':
          appointmentItems.map((item) => item.toJson()).toList(),
      'createdAt': createdAt,
      'endTime': endTime,
      'id': id,
      'startTime': startTime,
      'status': status,
      'userID': userID,
      'userName': userName,
    };
  }

  Appointment toEntity() {
    return Appointment(
      appointmentItems:
          appointmentItems.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      endTime: endTime,
      id: id,
      startTime: startTime,
      status: status,
      userID: userID,
      userName: userName,
    );
  }

  factory AppointmentModel.fromEntity(Appointment entity) {
    return AppointmentModel(
      appointmentItems:
          entity.appointmentItems
              .map((item) => AppointmentItemModel.fromEntity(item))
              .toList(),
      createdAt: entity.createdAt,
      endTime: entity.endTime,
      id: entity.id,
      startTime: entity.startTime,
      status: entity.status,
      userID: entity.userID,
      userName: entity.userName,
    );
  }
}

class UpdateAppointmentModel {
  final String? endTime;
  final String? startTime;
  final int? status;

  const UpdateAppointmentModel({this.endTime, this.startTime, this.status});

  factory UpdateAppointmentModel.fromJson(Map<String, dynamic> json) {
    return UpdateAppointmentModel(
      endTime: json['endTime'],
      startTime: json['startTime'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (endTime != null) json['endTime'] = endTime;
    if (startTime != null) json['startTime'] = startTime;
    if (status != null) json['status'] = status;

    return json;
  }

  UpdateAppointment toEntity() {
    return UpdateAppointment(
      endTime: endTime,
      startTime: startTime,
      status: status,
    );
  }

  factory UpdateAppointmentModel.fromEntity(UpdateAppointment entity) {
    return UpdateAppointmentModel(
      endTime: entity.endTime,
      startTime: entity.startTime,
      status: entity.status,
    );
  }
}
