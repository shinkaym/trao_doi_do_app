import 'package:dio/dio.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/message_response_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/message_query.dart';

abstract class MessageRemoteDataSource {
  Future<MessagesResponseModel> getMessages(MessagesQuery query);
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final DioClient _dioClient;

  MessageRemoteDataSourceImpl(this._dioClient);

  @override
  Future<MessagesResponseModel> getMessages(MessagesQuery query) async {
    final response = await _dioClient.get(
      '${ApiConstants.baseUrl}/messages',
      queryParameters: query.toQueryParams(),
      options: Options(extra: {'requiresAuth': true}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => MessagesResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }
}
