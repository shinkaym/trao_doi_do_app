import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/interest_response_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interests_query.dart';

abstract class InterestRemoteDataSource {
  Future<ApiResponseModel<InterestActionResponseModel>> createInterest(
    int postID,
  );
  Future<ApiResponseModel<InterestActionResponseModel>> cancelInterest(
    int postID,
  );
  Future<ApiResponseModel<InterestsResponseModel>> getInterests(
    InterestsQuery query,
  );
}

class InterestRemoteDataSourceImpl implements InterestRemoteDataSource {
  final DioClient _dioClient;

  InterestRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ApiResponseModel<InterestActionResponseModel>> createInterest(
    int postID,
  ) async {
    final response = await _dioClient.post(
      ApiConstants.interests,
      data: {'postID': postID},
    );

    return ApiResponseModel.fromJson(
      response.data,
      (json) =>
          InterestActionResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponseModel<InterestActionResponseModel>> cancelInterest(
    int postID,
  ) async {
    final response = await _dioClient.delete(
      '${ApiConstants.interests}/$postID',
    );

    return ApiResponseModel.fromJson(
      response.data,
      (json) =>
          InterestActionResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponseModel<InterestsResponseModel>> getInterests(
    InterestsQuery query,
  ) async {
    final response = await _dioClient.get(
      ApiConstants.interests,
      queryParameters: query.toQueryParams(),
    );

    return ApiResponseModel.fromJson(
      response.data,
      (json) => InterestsResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
