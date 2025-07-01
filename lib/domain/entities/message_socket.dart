class MessageSocket {
  final int? id;
  final int interestID;
  final String? roomID;
  final int senderID;
  final String message;
  final DateTime timestamp;
  final bool? isOwner;

  const MessageSocket({
    this.id,
    required this.interestID,
    this.roomID,
    required this.senderID,
    required this.message,
    required this.timestamp,
    this.isOwner,
  });

  factory MessageSocket.fromJson(Map<String, dynamic> json) {
    return MessageSocket(
      id: json['id'] as int?,
      interestID: json['interestID'] as int,
      roomID: json['roomID'] as String,
      senderID: json['senderID'] as int,
      message: json['message'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      isOwner: json['isOwner'] as bool?,
    );
  }

  MessageSocket copyWith({
    int? id,
    int? interestID,
    String? roomID,
    int? senderID,
    String? message,
    DateTime? timestamp,
    bool? isOwner,
  }) {
    return MessageSocket(
      id: id ?? this.id,
      interestID: interestID ?? this.interestID,
      roomID: roomID ?? this.roomID,
      senderID: senderID ?? this.senderID,
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
        other.interestID == interestID &&
        other.roomID == roomID &&
        other.senderID == senderID &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.isOwner == isOwner;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        interestID.hashCode ^
        roomID.hashCode ^
        senderID.hashCode ^
        message.hashCode ^
        timestamp.hashCode ^
        isOwner.hashCode;
  }

  @override
  String toString() {
    return 'MessageSocket(id: $id, interestID: $interestID, roomID: $roomID, senderID: $senderID, message: $message, timestamp: $timestamp, isOwner: $isOwner)';
  }
}
