import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';

/// Extension for handling repository exceptions in a consistent way
extension RepositoryHelper on Object {
  Future<Either<Failure, T>> handleRepositoryCall<T>(
    Future<T> Function() call, [
    String? errorPrefix,
  ]) async {
    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${errorPrefix ?? "Lỗi không xác định"}: $e'));
    }
  }

  Future<void> silentCall(Future<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      // Silent fail - add logging here if needed
      // Logger could be injected if required
    }
  }
}
