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

  // Factory constructor for creating Message from WebSocket data
  factory Message.fromWebSocket(
    Map<String, dynamic> data, {
    required int interestID,
    required int currentUserId,
    int? otherUserId,
  }) {
    final senderID = data['senderID'] as int;
    final receiverID =
        senderID == currentUserId ? (otherUserId ?? 0) : currentUserId;

    return Message(
      id: data['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      interestID: data['interestID'] as int? ?? interestID,
      senderID: senderID,
      receiverID: receiverID,
      message: data['message'] as String? ?? '',
      isRead: 0,
      createdAt:
          data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : data['timestamp'] != null
              ? DateTime.parse(data['timestamp'] as String)
              : DateTime.now(),
    );
  }

  // Factory constructor for creating Message from API response
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      interestID: json['interestID'] as int,
      senderID: json['senderID'] as int,
      receiverID: json['receiverID'] as int,
      message: json['message'] as String,
      isRead: json['isRead'] as int,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
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

  Message copyWith({
    int? id,
    int? interestID,
    int? senderID,
    int? receiverID,
    String? message,
    int? isRead,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      interestID: interestID ?? this.interestID,
      senderID: senderID ?? this.senderID,
      receiverID: receiverID ?? this.receiverID,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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

  @override
  String toString() {
    return 'Message(id: $id, interestID: $interestID, senderID: $senderID, receiverID: $receiverID, message: $message, isRead: $isRead, createdAt: $createdAt)';
  }
}
