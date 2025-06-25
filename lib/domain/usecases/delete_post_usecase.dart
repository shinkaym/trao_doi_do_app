import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';

class DeletePostUseCase {
  final PostRepository _repository;

  DeletePostUseCase(this._repository);

  Future<Either<Failure, String>> call(int postID) async {
    if (postID <= 0) {
      return const Left(ValidationFailure('ID bài đăng không hợp lệ'));
    }

    return await _repository.deletePost(postID);
  }
}
