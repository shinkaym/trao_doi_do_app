import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/interest_remote_datasource.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/params/interests_query.dart';
import 'package:trao_doi_do_app/domain/repositories/interest_repository.dart';

class InterestRepositoryImpl implements InterestRepository {
  final InterestRemoteDataSource _remoteDataSource;

  InterestRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, InterestActionResult>> createInterest(
    int postID,
  ) async {
    try {
      final apiResponse = await _remoteDataSource.createInterest(postID);

      if (apiResponse.code >= 200 &&
          apiResponse.code < 300 &&
          apiResponse.data != null) {
        final result = InterestActionResult(
          interestID: apiResponse.data!.interestID,
          message: apiResponse.message,
        );
        return Right(result);
      } else {
        return Left(
          ServerFailure(
            apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'Lỗi không xác định khi thể hiện quan tâm',
            apiResponse.code,
          ),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi thể hiện quan tâm'));
    }
  }

  @override
  Future<Either<Failure, InterestActionResult>> cancelInterest(
    int postID,
  ) async {
    try {
      final apiResponse = await _remoteDataSource.cancelInterest(postID);

      if (apiResponse.code >= 200 &&
          apiResponse.code < 300 &&
          apiResponse.data != null) {
        final result = InterestActionResult(
          interestID: apiResponse.data!.interestID,
          message: apiResponse.message,
        );
        return Right(result);
      } else {
        return Left(
          ServerFailure(
            apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'Lỗi không xác định khi hủy quan tâm',
            apiResponse.code,
          ),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi hủy quan tâm'));
    }
  }

  @override
  Future<Either<Failure, InterestsResult>> getInterests(
    InterestsQuery query,
  ) async {
    try {
      final apiResponse = await _remoteDataSource.getInterests(query);

      if (apiResponse.code >= 200 &&
          apiResponse.code < 300 &&
          apiResponse.data != null) {
        final interestsData = apiResponse.data!;

        final result = InterestsResult(
          interests: interestsData.interests.cast<InterestPost>(),
          totalPage: interestsData.totalPage,
        );

        return Right(result);
      } else {
        return Left(
          ServerFailure(
            apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'Lỗi không xác định khi tải danh sách quan tâm',
            apiResponse.code,
          ),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Lỗi không xác định khi tải danh sách quan tâm'),
      );
    }
  }
}
