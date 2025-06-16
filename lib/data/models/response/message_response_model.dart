import 'package:trao_doi_do_app/data/models/message_model.dart';
import 'package:trao_doi_do_app/domain/entities/response/message_response.dart';

class MessagesResponseModel {
  final List<MessageModel> messages;

  const MessagesResponseModel({required this.messages});

  factory MessagesResponseModel.fromJson(Map<String, dynamic> json) {
    return MessagesResponseModel(
      messages:
          (json['messages'] as List<dynamic>)
              .map(
                (message) =>
                    MessageModel.fromJson(message as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'messages': messages.map((message) => message.toJson()).toList()};
  }

  MessagesResponse toEntity() {
    return MessagesResponse(
      messages: messages.map((message) => message.toEntity()).toList(),
    );
  }

  factory MessagesResponseModel.fromEntity(MessagesResponse entity) {
    return MessagesResponseModel(
      messages:
          entity.messages
              .map((message) => MessageModel.fromEntity(message))
              .toList(),
    );
  }
}
