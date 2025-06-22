class ChatNotification {
  final int interestID;
  final String type;
  final int senderID;
  final DateTime timestamp;

  const ChatNotification({
    required this.interestID,
    required this.type,
    required this.senderID,
    required this.timestamp,
  });

  factory ChatNotification.fromJson(Map<String, dynamic> json) {
    return ChatNotification(
      interestID: json['interestID'] as int,
      type: json['type'] as String,
      senderID: json['senderID'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'ChatNotification(interestID: $interestID, type: $type, senderID: $senderID, timestamp: $timestamp)';
  }
}
