class ChatNotification {
  final int interestID;
  final String type;
  final int userID;
  final DateTime timestamp;

  const ChatNotification({
    required this.interestID,
    required this.type,
    required this.userID,
    required this.timestamp,
  });

  factory ChatNotification.fromJson(Map<String, dynamic> json) {
    return ChatNotification(
      interestID: json['interestID'] as int,
      type: json['type'] as String,
      userID: json['userID'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'ChatNotification(interestID: $interestID, type: $type, userID: $userID, timestamp: $timestamp)';
  }
}
