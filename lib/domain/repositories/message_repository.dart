import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/message_response.dart';
import 'package:trao_doi_do_app/domain/usecases/params/message_query.dart';

abstract class MessageRepository {
  Future<Either<Failure, MessagesResponse>> getMessages(MessagesQuery query);
}
