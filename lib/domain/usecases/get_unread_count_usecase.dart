import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/interest_repository.dart';

class GetUnreadCountUseCase {
  final InterestRepository _repository;

  GetUnreadCountUseCase(this._repository);

  Future<Either<Failure, int>> call() async {
    return await _repository.getUnreadCount();
  }
}
