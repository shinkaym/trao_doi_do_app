import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/interest_response_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interest_query.dart';

abstract class InterestRemoteDataSource {
  Future<InterestActionResponseModel> createInterest(int postID);
  Future<InterestActionResponseModel> cancelInterest(int postID);
  Future<InterestsResponseModel> getInterests(InterestsQuery query);
}

class InterestRemoteDataSourceImpl implements InterestRemoteDataSource {
  final DioClient _dioClient;

  InterestRemoteDataSourceImpl(this._dioClient);

  @override
  Future<InterestActionResponseModel> createInterest(int postID) async {
    final response = await _dioClient.post(
      ApiConstants.interests,
      data: {'postID': postID},
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) =>
          InterestActionResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<InterestActionResponseModel> cancelInterest(int postID) async {
    final response = await _dioClient.delete(
      '${ApiConstants.interests}/$postID',
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) =>
          InterestActionResponseModel.fromJson(json as Map<String, dynamic>),
    );
    return result.data!;
  }

  @override
  Future<InterestsResponseModel> getInterests(InterestsQuery query) async {
    final response = await _dioClient.get(
      ApiConstants.interests,
      queryParameters: query.toQueryParams(),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => InterestsResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }
}
