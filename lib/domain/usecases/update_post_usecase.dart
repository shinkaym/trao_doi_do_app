import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository _repository;

  UpdatePostUseCase(this._repository);

  Future<Either<Failure, dynamic>> call(
    int postID,
    UpdatePost updatePost,
  ) async {
    // Validation
    // if (updatePost.title.trim().isEmpty) {
    //   return const Left(ValidationFailure('Tiêu đề không được để trống'));
    // }

    // if (updatePost.description.trim().isEmpty) {
    //   return const Left(ValidationFailure('Mô tả không được để trống'));
    // }

    // if (updatePost.status < 1 || updatePost.status > 4) {
    //   return const Left(ValidationFailure('Trạng thái không hợp lệ'));
    // }

    return await _repository.updatePost(postID, updatePost);
  }
}
