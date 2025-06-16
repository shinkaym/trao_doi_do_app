import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/message_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/response/message_response.dart';
import 'package:trao_doi_do_app/domain/repositories/message_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/params/message_query.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource _remoteDataSource;

  MessageRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, MessagesResponse>> getMessages(
    MessagesQuery query,
  ) async {
    return handleRepositoryCall<MessagesResponse>(() async {
      final remoteResponse = await _remoteDataSource.getMessages(query);
      final messagesEntity = remoteResponse.toEntity();
      return messagesEntity;
    }, 'Lỗi tải danh sách tin nhắn');
  }
}
