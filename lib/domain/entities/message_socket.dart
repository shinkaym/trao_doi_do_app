class MessageSocket {
  final int? id;
  final int senderID;
  final String roomID;
  final String message;
  final DateTime timestamp;
  final bool isOwner;

  const MessageSocket({
    this.id,
    required this.senderID,
    required this.roomID,
    required this.message,
    required this.timestamp,
    required this.isOwner,
  });

  MessageSocket copyWith({
    int? id,
    int? senderID,
    String? roomID,
    String? message,
    DateTime? timestamp,
    bool? isOwner,
  }) {
    return MessageSocket(
      id: id ?? this.id,
      senderID: senderID ?? this.senderID,
      roomID: roomID ?? this.roomID,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageSocket &&
        other.id == id &&
        other.senderID == senderID &&
        other.roomID == roomID &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.isOwner == isOwner;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        senderID.hashCode ^
        roomID.hashCode ^
        message.hashCode ^
        timestamp.hashCode ^
        isOwner.hashCode;
  }

  @override
  String toString() {
    return 'Message(id: $id, senderID: $senderID, roomID: $roomID, message: $message, timestamp: $timestamp, isOwner: $isOwner)';
  }
}
