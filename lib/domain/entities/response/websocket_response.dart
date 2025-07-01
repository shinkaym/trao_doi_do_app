class WebSocketResponse {
  final String event;
  final String status;
  final Map<String, dynamic>? data;
  final String? error;
  final String? sourceChannel;

  const WebSocketResponse({
    required this.event,
    required this.status,
    this.data,
    this.error,
    this.sourceChannel,
  });

  factory WebSocketResponse.fromJson(Map<String, dynamic> json) {
    return WebSocketResponse(
      event: json['event'] as String,
      status: json['status'] as String,
      data: json['data'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      // sourceChannel will be set later by MultiWebSocketManager
    );
  }

  WebSocketResponse copyWithSourceChannel({required String sourceChannel}) {
    return WebSocketResponse(
      event: event,
      status: status,
      data: data,
      error: error,
      sourceChannel: sourceChannel,
    );
  }

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  bool get isFromChat => sourceChannel == 'chat';
  bool get isFromChatNotification => sourceChannel == 'chat-noti';

  @override
  String toString() {
    return 'WebSocketResponse(event: $event, status: $status, data: $data, error: $error, sourceChannel: $sourceChannel)';
  }
}
