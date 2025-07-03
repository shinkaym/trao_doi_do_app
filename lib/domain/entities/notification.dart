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
