import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/interest_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/usecases/params/interests_query.dart';
import 'package:trao_doi_do_app/domain/repositories/interest_repository.dart';

class InterestRepositoryImpl implements InterestRepository {
  final InterestRemoteDataSource _remoteDataSource;

  InterestRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, InterestActionResult>> createInterest(
    int postID,
  ) async {
    return handleRepositoryCall(() async {
      final response = await _remoteDataSource.createInterest(postID);
      return InterestActionResult(
        interestID: response.interestID,
        message: 'Đã thể hiện quan tâm thành công',
      );
    }, 'Lỗi khi thể hiện quan tâm');
  }

  @override
  Future<Either<Failure, InterestActionResult>> cancelInterest(
    int postID,
  ) async {
    return handleRepositoryCall(() async {
      final response = await _remoteDataSource.cancelInterest(postID);
      return InterestActionResult(
        interestID: response.interestID,
        message: 'Đã hủy quan tâm thành công',
      );
    }, 'Lỗi khi hủy quan tâm');
  }

  @override
  Future<Either<Failure, InterestsResult>> getInterests(
    InterestsQuery query,
  ) async {
    return handleRepositoryCall(() async {
      final response = await _remoteDataSource.getInterests(query);
      return InterestsResult(
        interests: response.interests.map((e) => e.toEntity()).toList(),
        totalPage: response.totalPage,
      );
    }, 'Lỗi khi tải danh sách quan tâm');
  }
}
