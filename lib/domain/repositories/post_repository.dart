import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';

abstract class PostRepository {
  Future<Either<Failure, void>> createPost(Post post);
}
