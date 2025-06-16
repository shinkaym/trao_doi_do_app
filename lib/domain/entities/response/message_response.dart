import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/message.dart';

class MessagesResponse extends Equatable {
  final List<Message> messages;

  const MessagesResponse({required this.messages});

  @override
  List<Object?> get props => [messages];
}
