import 'package:trao_doi_do_app/domain/entities/message.dart';

class MessageModel {
  final int id;
  final int interestID;
  final int senderID;
  final int receiverID;
  final String message;
  final int isRead;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.interestID,
    required this.senderID,
    required this.receiverID,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      interestID: json['interestID'] as int,
      senderID: json['senderID'] as int,
      receiverID: json['receiverID'] as int,
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as int? ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interestID': interestID,
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Message toEntity() {
    return Message(
      id: id,
      interestID: interestID,
      senderID: senderID,
      receiverID: receiverID,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  factory MessageModel.fromEntity(Message entity) {
    return MessageModel(
      id: entity.id,
      interestID: entity.interestID,
      senderID: entity.senderID,
      receiverID: entity.receiverID,
      message: entity.message,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }
}
