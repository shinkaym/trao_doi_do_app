import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';
import 'package:trao_doi_do_app/domain/repositories/ranking_repository.dart';

class GetMyGoodDeedsUseCase {
  final RankingRepository _repository;

  GetMyGoodDeedsUseCase(this._repository);

  Future<Either<Failure, MyGoodDeedsResponse>> call() async {
    return await _repository.getMyGoodDeeds();
  }
}