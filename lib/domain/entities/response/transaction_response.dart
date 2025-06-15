import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';

class TransactionsResponse extends Equatable {
  final List<Transaction> transactions;
  final int totalPage;

  const TransactionsResponse({
    required this.transactions,
    required this.totalPage,
  });

  @override
  List<Object?> get props => [transactions, totalPage];
}
