import 'package:trao_doi_do_app/domain/entities/notification.dart';

class NotificationModel {
  final int id;
  final String content;
  final String createdAt;
  final bool isRead;
  final int receiverID;
  final String receiverName;
  final int senderID;
  final String senderName;
  final int targetID;
  final String targetType;
  final String type;

  const NotificationModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.isRead,
    required this.receiverID,
    required this.receiverName,
    required this.senderID,
    required this.senderName,
    required this.targetID,
    required this.targetType,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isRead: json['isRead'] ?? false,
      receiverID: json['receiverID'] ?? 0,
      receiverName: json['receiverName'] ?? '',
      senderID: json['senderID'] ?? 0,
      senderName: json['senderName'] ?? '',
      targetID: json['targetID'] ?? 0,
      targetType: json['targetType'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt,
      'isRead': isRead,
      'receiverID': receiverID,
      'receiverName': receiverName,
      'senderID': senderID,
      'senderName': senderName,
      'targetID': targetID,
      'targetType': targetType,
      'type': type,
    };
  }

  Notification toEntity() {
    return Notification(
      id: id,
      content: content,
      createdAt: createdAt,
      isRead: isRead,
      receiverID: receiverID,
      receiverName: receiverName,
      senderID: senderID,
      senderName: senderName,
      targetID: targetID,
      targetType: targetType,
      type: type,
    );
  }

  factory NotificationModel.fromEntity(Notification entity) {
    return NotificationModel(
      id: entity.id,
      content: entity.content,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
      receiverID: entity.receiverID,
      receiverName: entity.receiverName,
      senderID: entity.senderID,
      senderName: entity.senderName,
      targetID: entity.targetID,
      targetType: entity.targetType,
      type: entity.type,
    );
  }
}
