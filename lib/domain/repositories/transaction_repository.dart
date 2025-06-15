import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/models/transaction_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/transaction_query.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';

class TransactionsResult {
  final List<Transaction> transactions;
  final int totalPage;

  const TransactionsResult({
    required this.transactions,
    required this.totalPage,
  });
}

abstract class TransactionRepository {
  Future<Either<Failure, TransactionsResult>> getTransactions(
    TransactionsQuery query,
  );

  Future<Either<Failure, Transaction>> createTransaction(
    CreateTransactionModel transaction,
  );

  Future<Either<Failure, Transaction>> updateTransaction(
    int transactionID,
    UpdateTransactionModel transaction,
  );

  Future<Either<Failure, Transaction>> updateTransactionStatus(
    int transactionID,
    UpdateTransactionStatusModel transaction,
  );
}
