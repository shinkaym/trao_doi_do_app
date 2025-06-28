import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';

abstract class RankingRepository {
  Future<Either<Failure, UserRankingResponse>> getUserRanks(
    int page,
    int limit,
  );
  Future<Either<Failure, MyGoodDeedsResponse>> getMyGoodDeeds();
}
