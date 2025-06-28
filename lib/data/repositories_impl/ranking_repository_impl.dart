import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/ranking_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';
import 'package:trao_doi_do_app/domain/repositories/ranking_repository.dart';

class RankingRepositoryImpl implements RankingRepository {
  final RankingRemoteDataSource _remoteDataSource;

  RankingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserRankingResponse>> getUserRanks(
    int page,
    int limit,
  ) async {
    return handleRepositoryCall<UserRankingResponse>(() async {
      final remoteResponse = await _remoteDataSource.getUserRanks(page, limit);
      final rankingEntity = remoteResponse.toEntity();
      return rankingEntity;
    }, 'Lỗi tải bảng xếp hạng');
  }

  @override
  Future<Either<Failure, MyGoodDeedsResponse>> getMyGoodDeeds() async {
    return handleRepositoryCall<MyGoodDeedsResponse>(() async {
      final remoteResponse = await _remoteDataSource.getMyGoodDeeds();
      final goodDeedsEntity = remoteResponse.toEntity();
      return goodDeedsEntity;
    }, 'Lỗi tải lịch sử thiện nguyện');
  }
}
