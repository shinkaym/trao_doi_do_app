// /lib/domain/repositories/transaction_repository.dart
import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/transaction_request.dart';
import 'package:trao_doi_do_app/domain/entities/response/transaction_response.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/domain/usecases/params/transaction_query.dart';

abstract class TransactionRepository {
  Future<Either<Failure, TransactionsResponse>> getTransactions(
    TransactionsQuery query,
  );

  // ✅ Sử dụng Domain entities
  Future<Either<Failure, Transaction>> createTransaction(
    CreateTransactionRequest request,
  );

  Future<Either<Failure, Transaction>> updateTransaction(
    int transactionID,
    UpdateTransactionRequest request,
  );

  Future<Either<Failure, Transaction>> updateTransactionStatus(
    int transactionID,
    UpdateTransactionStatusRequest request,
  );
}