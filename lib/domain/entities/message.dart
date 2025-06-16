import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final int id;
  final int interestID;
  final int senderID;
  final int receiverID;
  final String message;
  final int isRead; // 0: unread, 1: read
  final DateTime? createdAt;

  const Message({
    required this.id,
    required this.interestID,
    required this.senderID,
    required this.receiverID,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        interestID,
        senderID,
        receiverID,
        message,
        isRead,
        createdAt,
      ];
}