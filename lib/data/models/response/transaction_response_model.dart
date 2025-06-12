import 'package:trao_doi_do_app/data/models/transaction_model.dart';

class TransactionsResponseModel {
  final List<TransactionModel> transactions;
  final int totalPage;

  const TransactionsResponseModel({
    required this.transactions,
    required this.totalPage,
  });

  factory TransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionsResponseModel(
      transactions:
          (json['transactions'] as List<dynamic>)
              .map(
                (transaction) => TransactionModel.fromJson(
                  transaction as Map<String, dynamic>,
                ),
              )
              .toList(),
      totalPage: json['totalPage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactions':
          transactions.map((transaction) => transaction.toJson()).toList(),
      'totalPage': totalPage,
    };
  }
}
