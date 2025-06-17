import 'package:trao_doi_do_app/domain/entities/response/websocket_response.dart';
import 'package:trao_doi_do_app/domain/repositories/websocket_repository.dart';
import 'package:trao_doi_do_app/core/network/websocket_client.dart';

class ConnectWebSocketUseCase {
  final WebSocketRepository _repository;

  ConnectWebSocketUseCase(this._repository);

  Future<void> call(String? token) async {
    await _repository.connect(token);
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

  void call({required bool isOwner, required int userID}) {
    _repository.joinRoom(isOwner: isOwner, userID: userID);
  }
}

class LeftRoomUseCase {
  final WebSocketRepository _repository;

  LeftRoomUseCase(this._repository);

  void call({required bool isOwner, required int userID}) {
    _repository.leftRoom(isOwner: isOwner, userID: userID);
  }
}

class SendMessageUseCase {
  final WebSocketRepository _repository;

  SendMessageUseCase(this._repository);

  void call({
    required bool isOwner,
    required int userID,
    required String message,
  }) {
    _repository.sendMessage(isOwner: isOwner, userID: userID, message: message);
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
