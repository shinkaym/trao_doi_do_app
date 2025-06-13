import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/repositories_impl/auth_repository_impl.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository _repository;

  GetMeUseCase(this._repository);

  Future<Either<Failure, User>> call() async {
    return await _repository.getMe();
  }
}

final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetMeUseCase(repository);
});
