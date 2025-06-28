import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/ranking_model.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';

abstract class RankingRemoteDataSource {
  Future<UserRankingResponseModel> getUserRanks(int page, int limit);
  Future<MyGoodDeedsResponseModel> getMyGoodDeeds();
}

class RankingRemoteDataSourceImpl implements RankingRemoteDataSource {
  final DioClient _dioClient;

  RankingRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserRankingResponseModel> getUserRanks(int page, int limit) async {
    final response = await _dioClient.get(
      ApiConstants.ranks,
      queryParameters: {'page': page, 'limit': limit},
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => UserRankingResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<MyGoodDeedsResponseModel> getMyGoodDeeds() async {
    final response = await _dioClient.get(ApiConstants.myRanks);

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => MyGoodDeedsResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }
}
