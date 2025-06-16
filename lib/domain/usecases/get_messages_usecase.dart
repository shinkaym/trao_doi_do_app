import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/message_response.dart';
import 'package:trao_doi_do_app/domain/usecases/params/message_query.dart';
import 'package:trao_doi_do_app/domain/repositories/message_repository.dart';

class GetMessagesUseCase {
  final MessageRepository _repository;

  GetMessagesUseCase(this._repository);

  Future<Either<Failure, MessagesResponse>> call(MessagesQuery query) async {
    return await _repository.getMessages(query);
  }
}
