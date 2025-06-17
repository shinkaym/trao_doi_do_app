enum WebSocketEventType {
  joinRoom('join_room'),
  leftRoom('left_room'),
  sendMessage('send_message'),
  ping('ping'),
  pong('pong');

  const WebSocketEventType(this.value);
  final String value;

  static WebSocketEventType? fromString(String value) {
    for (WebSocketEventType type in WebSocketEventType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

class WebSocketEvent {
  final WebSocketEventType event;
  final Map<String, dynamic> data;

  const WebSocketEvent({required this.event, required this.data});

  factory WebSocketEvent.joinRoom({
    required bool isOwner,
    required int userID,
  }) {
    return WebSocketEvent(
      event: WebSocketEventType.joinRoom,
      data: {'isOwner': isOwner, 'userID': userID},
    );
  }

  factory WebSocketEvent.leftRoom({
    required bool isOwner,
    required int userID,
  }) {
    return WebSocketEvent(
      event: WebSocketEventType.leftRoom,
      data: {'isOwner': isOwner, 'userID': userID},
    );
  }

  factory WebSocketEvent.sendMessage({
    required bool isOwner,
    required int userID,
    required String message,
  }) {
    return WebSocketEvent(
      event: WebSocketEventType.sendMessage,
      data: {'isOwner': isOwner, 'userID': userID, 'message': message},
    );
  }

  Map<String, dynamic> toJson() {
    return {'event': event.value, 'data': data};
  }

  @override
  String toString() => 'WebSocketEvent(event: ${event.value}, data: $data)';
}
