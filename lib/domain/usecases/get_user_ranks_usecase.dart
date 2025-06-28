import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';
import 'package:trao_doi_do_app/domain/repositories/ranking_repository.dart';

class GetUserRanksUseCase {
  final RankingRepository _repository;

  GetUserRanksUseCase(this._repository);

  Future<Either<Failure, UserRankingResponse>> call(int page, int limit) async {
    return await _repository.getUserRanks(page, limit);
  }
}
