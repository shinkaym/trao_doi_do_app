import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/extensions/repository_extensions.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:trao_doi_do_app/data/models/response/transaction_response_model.dart';
import 'package:trao_doi_do_app/domain/entities/request/transaction_request.dart';
import 'package:trao_doi_do_app/domain/entities/response/transaction_response.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/repositories/transaction_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/params/transaction_query.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, TransactionsResponse>> getTransactions(
    TransactionsQuery query,
  ) async {
    return handleRepositoryCall<TransactionsResponse>(() async {
      final remoteResponse = await _remoteDataSource.getTransactions(query);
      final transactionEntity = remoteResponse.toEntity();
      return transactionEntity;
    }, 'Lỗi khi tải danh sách giao dịch');
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction(
    CreateTransactionRequest request, // ✅ Domain entity
  ) async {
    return handleRepositoryCall<Transaction>(() async {
      final dataModel = _mapToCreateTransactionModel(request);
      final remoteResponse = await _remoteDataSource.createTransaction(
        dataModel,
      );
      return remoteResponse.toEntity();
    }, 'Lỗi khi tạo giao dịch');
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    int transactionID,
    UpdateTransactionRequest request,
  ) async {
    return handleRepositoryCall<Transaction>(() async {
      final dataModel = _mapToUpdateTransactionModel(request);
      final remoteResponse = await _remoteDataSource.updateTransaction(
        transactionID,
        dataModel,
      );
      return remoteResponse.toEntity();
    }, 'Lỗi khi cập nhật giao dịch');
  }

  @override
  Future<Either<Failure, Transaction>> updateTransactionStatus(
    int transactionID,
    UpdateTransactionStatusRequest request,
  ) async {
    return handleRepositoryCall<Transaction>(() async {
      final dataModel = _mapToUpdateTransactionStatusModel(request);
      final remoteResponse = await _remoteDataSource.updateTransactionStatus(
        transactionID,
        dataModel,
      );
      return remoteResponse.toEntity();
    }, 'Lỗi khi cập nhật trạng thái giao dịch');
  }

  CreateTransactionRequestModel _mapToCreateTransactionModel(
    CreateTransactionRequest request,
  ) {
    return CreateTransactionRequestModel(
      interestID: request.interestID,
      items:
          request.items
              .map(
                (item) => CreateTransactionItemRequestModel(
                  postItemID: item.postItemID,
                  quantity: item.quantity,
                ),
              )
              .toList(),
    );
  }

  UpdateTransactionRequestModel _mapToUpdateTransactionModel(
    UpdateTransactionRequest request,
  ) {
    return UpdateTransactionRequestModel(
      items:
          request.items
              .map(
                (item) => UpdateTransactionItemRequestModel(
                  postItemID: item.postItemID,
                  quantity: item.quantity,
                  transactionID: item.transactionID,
                ),
              )
              .toList(),
      status: request.status,
    );
  }

  UpdateTransactionStatusRequestModel _mapToUpdateTransactionStatusModel(
    UpdateTransactionStatusRequest request,
  ) {
    return UpdateTransactionStatusRequestModel(status: request.status);
  }
}
