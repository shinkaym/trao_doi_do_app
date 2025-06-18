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

  factory WebSocketEvent.joinRoom({required int interestID}) {
    return WebSocketEvent(
      event: WebSocketEventType.joinRoom,
      data: {'interestID': interestID},
    );
  }

  factory WebSocketEvent.leftRoom({required int interestID}) {
    return WebSocketEvent(
      event: WebSocketEventType.leftRoom,
      data: {'interestID': interestID},
    );
  }

  factory WebSocketEvent.sendMessage({
    required int interestID,
    required bool isOwner,
    required int userID,
    required String message,
  }) {
    return WebSocketEvent(
      event: WebSocketEventType.sendMessage,
      data: {
        'interestID': interestID,
        'isOwner': isOwner,
        'userID': userID,
        'message': message,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {'event': event.value, 'data': data};
  }

  @override
  String toString() => 'WebSocketEvent(event: ${event.value}, data: $data)';
}
