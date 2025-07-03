class NotificationSocket {
  final int id;
  final int? senderID;
  final String? senderName;
  final int? receiverID;
  final String? receiverName;
  final String type; // normal/system
  final String targetType; // interest, post, appointment
  final int targetID;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const NotificationSocket({
    required this.id,
    this.senderID,
    this.senderName,
    this.receiverID,
    this.receiverName,
    required this.type,
    required this.targetType,
    required this.targetID,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationSocket.fromJson(Map<String, dynamic> json) {
    return NotificationSocket(
      id: json['id'] as int,
      senderID: json['senderID'] == 0 ? null : json['senderID'] as int?,
      senderName:
          json['senderName'] == null || json['senderName'] == ''
              ? null
              : json['senderName'] as String?,
      receiverID: json['receiverID'] as int?,
      receiverName:
          json['receiverName'] == null || json['receiverName'] == ''
              ? null
              : json['receiverName'] as String?,
      type: json['type'] as String,
      targetType: json['targetType'] as String,
      targetID: json['targetID'] as int,
      content: json['content'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  NotificationSocket copyWith({
    int? id,
    int? senderID,
    String? senderName,
    int? receiverID,
    String? receiverName,
    String? type,
    String? targetType,
    int? targetID,
    String? content,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationSocket(
      id: id ?? this.id,
      senderID: senderID ?? this.senderID,
      senderName: senderName ?? this.senderName,
      receiverID: receiverID ?? this.receiverID,
      receiverName: receiverName ?? this.receiverName,
      type: type ?? this.type,
      targetType: targetType ?? this.targetType,
      targetID: targetID ?? this.targetID,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isNormalType => type == 'normal';
  bool get isSystemType => type == 'system';
  bool get isInterestType => targetType == 'interest';
  bool get isPostType => targetType == 'post';
  bool get isAppointmentType => targetType == 'appointment';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSocket &&
        other.id == id &&
        other.senderID == senderID &&
        other.senderName == senderName &&
        other.receiverID == receiverID &&
        other.receiverName == receiverName &&
        other.type == type &&
        other.targetType == targetType &&
        other.targetID == targetID &&
        other.content == content &&
        other.isRead == isRead &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        senderID.hashCode ^
        senderName.hashCode ^
        receiverID.hashCode ^
        receiverName.hashCode ^
        type.hashCode ^
        targetType.hashCode ^
        targetID.hashCode ^
        content.hashCode ^
        isRead.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'NotificationSocket(id: $id, senderID: $senderID, senderName: $senderName, receiverID: $receiverID, receiverName: $receiverName, type: $type, targetType: $targetType, targetID: $targetID, content: $content, isRead: $isRead, createdAt: $createdAt)';
  }
}
