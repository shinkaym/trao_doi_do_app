// lib/domain/usecases/get_interests_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/repositories_impl/interest_repository_impl.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/params/interests_query.dart';
import 'package:trao_doi_do_app/domain/repositories/interest_repository.dart';

class GetInterestsUseCase {
  final InterestRepository _repository;

  GetInterestsUseCase(this._repository);

  Future<Either<Failure, InterestsResult>> call(InterestsQuery query) async {
    return await _repository.getInterests(query);
  }
}

final getInterestsUseCaseProvider = Provider<GetInterestsUseCase>((ref) {
  final repository = ref.watch(interestRepositoryProvider);
  return GetInterestsUseCase(repository);
});