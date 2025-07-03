import 'package:equatable/equatable.dart';

class Notification extends Equatable {
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

  const Notification({
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

  Notification copyWith({
    int? id,
    String? content,
    String? createdAt,
    bool? isRead,
    int? receiverID,
    String? receiverName,
    int? senderID,
    String? senderName,
    int? targetID,
    String? targetType,
    String? type,
  }) {
    return Notification(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      receiverID: receiverID ?? this.receiverID,
      receiverName: receiverName ?? this.receiverName,
      senderID: senderID ?? this.senderID,
      senderName: senderName ?? this.senderName,
      targetID: targetID ?? this.targetID,
      targetType: targetType ?? this.targetType,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    createdAt,
    isRead,
    receiverID,
    receiverName,
    senderID,
    senderName,
    targetID,
    targetType,
    type,
  ];
}
