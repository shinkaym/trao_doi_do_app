import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/repositories/websocket_repository.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';

class ConnectToChatUseCase {
  final WebSocketRepository _repository;

  ConnectToChatUseCase(this._repository);

  Future<void> call(String? token) async {
    await _repository.connectToChat(token);
  }
}

class ConnectToChatNotificationUseCase {
  final WebSocketRepository _repository;

  ConnectToChatNotificationUseCase(this._repository);

  Future<void> call(String? token) async {
    await _repository.connectToChatNotification(token);
  }
}

class DisconnectWebSocketUseCase {
  final WebSocketRepository _repository;

  DisconnectWebSocketUseCase(this._repository);

  void call() {
    _repository.disconnect();
  }
}

class JoinRoomUseCase {
  final WebSocketRepository _repository;

  JoinRoomUseCase(this._repository);

  void call({required int interestID}) {
    _repository.joinRoom(interestID: interestID);
  }
}

class LeftRoomUseCase {
  final WebSocketRepository _repository;

  LeftRoomUseCase(this._repository);

  void call({required int interestID}) {
    _repository.leftRoom(interestID: interestID);
  }
}

class SendMessageUseCase {
  final WebSocketRepository _repository;

  SendMessageUseCase(this._repository);

  void call({
    required int interestID,
    required bool isOwner,
    required int userID,
    required String message,
  }) {
    _repository.sendMessage(
      interestID: interestID,
      isOwner: isOwner,
      userID: userID,
      message: message,
    );
  }
}

class SendTransactionUseCase {
  final WebSocketRepository _repository;

  SendTransactionUseCase(this._repository);

  void call({required int interestID, required int receiverID}) {
    _repository.sendTransaction(interestID: interestID, receiverID: receiverID);
  }
}

class GetWebSocketResponseStreamUseCase {
  final WebSocketRepository _repository;

  GetWebSocketResponseStreamUseCase(this._repository);

  Stream<WebSocketResponse> call() {
    return _repository.responseStream;
  }
}

class GetWebSocketConnectionStreamUseCase {
  final WebSocketRepository _repository;

  GetWebSocketConnectionStreamUseCase(this._repository);

  Stream<WebSocketConnectionState> call() {
    return _repository.connectionStream;
  }
}
