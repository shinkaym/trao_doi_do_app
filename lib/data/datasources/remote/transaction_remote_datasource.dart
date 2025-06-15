import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/transaction_response_model.dart';
import 'package:trao_doi_do_app/data/models/transaction_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/transaction_query.dart';

abstract class TransactionRemoteDataSource {
  Future<TransactionsResponseModel> getTransactions(TransactionsQuery query);
  Future<TransactionModel> createTransaction(
    CreateTransactionRequestModel transaction,
  );
  Future<TransactionModel> updateTransaction(
    int transactionID,
    UpdateTransactionRequestModel transaction,
  );
  Future<TransactionModel> updateTransactionStatus(
    int transactionID,
    UpdateTransactionStatusRequestModel transaction,
  );
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final DioClient _dioClient;

  TransactionRemoteDataSourceImpl(this._dioClient);

  @override
  Future<TransactionsResponseModel> getTransactions(
    TransactionsQuery query,
  ) async {
    final response = await _dioClient.get(
      ApiConstants.transactions,
      queryParameters: query.toQueryParams(),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) =>
          TransactionsResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<TransactionModel> createTransaction(
    CreateTransactionRequestModel transaction,
  ) async {
    final response = await _dioClient.post(
      ApiConstants.transactions,
      data: transaction.toJson(),
    );

    final result = ApiResponseModel.fromJson(response.data, (json) {
      final map = json as Map<String, dynamic>;
      return TransactionModel.fromJson(map['transaction'] ?? map);
    });

    return result.data!;
  }

  @override
  Future<TransactionModel> updateTransaction(
    int transactionID,
    UpdateTransactionRequestModel transaction,
  ) async {
    final response = await _dioClient.patch(
      '${ApiConstants.transactions}/$transactionID',
      data: transaction.toJson(),
    );

    final result = ApiResponseModel.fromJson(response.data, (json) {
      final map = json as Map<String, dynamic>;
      return TransactionModel.fromJson(map['transaction'] ?? map);
    });

    return result.data!;
  }

  @override
  Future<TransactionModel> updateTransactionStatus(
    int transactionID,
    UpdateTransactionStatusRequestModel transaction,
  ) async {
    final response = await _dioClient.patch(
      '${ApiConstants.transactions}/$transactionID',
      data: transaction.toJson(),
    );

    final result = ApiResponseModel.fromJson(response.data, (json) {
      final map = json as Map<String, dynamic>;
      return TransactionModel.fromJson(map['transaction'] ?? map);
    });

    return result.data!;
  }
}
