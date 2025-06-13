import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:trao_doi_do_app/data/models/transaction_model.dart';
import 'package:trao_doi_do_app/domain/entities/params/transactions_query.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, TransactionsResult>> getTransactions(
    TransactionsQuery query,
  ) async {
    try {
      final apiResponse = await _remoteDataSource.getTransactions(query);

      if (apiResponse.code >= 200 &&
          apiResponse.code < 300 &&
          apiResponse.data != null) {
        final transactionsData = apiResponse.data!;

        final result = TransactionsResult(
          transactions: transactionsData.transactions,
          totalPage: transactionsData.totalPage,
        );

        return Right(result);
      } else {
        return Left(
          ServerFailure(
            apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'Lỗi không xác định khi tải danh sách giao dịch',
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
        ServerFailure('Lỗi không xác định khi tải danh sách giao dịch'),
      );
    }
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction(
    CreateTransactionModel transaction,
  ) async {
    try {
      final apiResponse = await _remoteDataSource.createTransaction(
        transaction,
      );

      if (apiResponse.code >= 200 &&
          apiResponse.code < 300 &&
          apiResponse.data != null) {
        return Right(apiResponse.data!);
      } else {
        return Left(
          ServerFailure(
            apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'Lỗi không xác định khi tạo giao dịch',
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
      return Left(ServerFailure('Lỗi không xác định khi tạo giao dịch'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    int transactionID,
    UpdateTransactionModel transaction,
  ) async {
    try {
      final apiResponse = await _remoteDataSource.updateTransaction(
        transactionID,
        transaction,
      );

      if (apiResponse.code >= 200 &&
          apiResponse.code < 300 &&
          apiResponse.data != null) {
        return Right(apiResponse.data!);
      } else {
        return Left(
          ServerFailure(
            apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'Lỗi không xác định khi cập nhật giao dịch',
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
      return Left(ServerFailure('Lỗi không xác định khi cập nhật giao dịch'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransactionStatus(
    int transactionID,
    UpdateTransactionStatusModel transaction,
  ) async {
    try {
      final apiResponse = await _remoteDataSource.updateTransactionStatus(
        transactionID,
        transaction,
      );

      if (apiResponse.code >= 200 &&
          apiResponse.code < 300 &&
          apiResponse.data != null) {
        return Right(apiResponse.data!);
      } else {
        return Left(
          ServerFailure(
            apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'Lỗi không xác định khi cập nhật trạng thái giao dịch',
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
      return Left(
        ServerFailure('Lỗi không xác định khi cập nhật trạng thái giao dịch'),
      );
    }
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final remoteDataSource = ref.watch(transactionRemoteDataSourceProvider);
  return TransactionRepositoryImpl(remoteDataSource);
});
