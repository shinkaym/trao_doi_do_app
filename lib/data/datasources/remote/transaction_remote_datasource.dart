import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/transaction_response_model.dart';
import 'package:trao_doi_do_app/data/models/transaction_model.dart';
import 'package:trao_doi_do_app/domain/entities/params/transactions_query.dart';

abstract class TransactionRemoteDataSource {
  Future<ApiResponseModel<TransactionsResponseModel>> getTransactions(
    TransactionsQuery query,
  );
  Future<ApiResponseModel<TransactionModel>> createTransaction(
    CreateTransactionModel transaction,
  );
  Future<ApiResponseModel<TransactionModel>> updateTransaction(
    int transactionID,
    UpdateTransactionModel transaction,
  );
  Future<ApiResponseModel<TransactionModel>> updateTransactionStatus(
    int transactionID,
    UpdateTransactionStatusModel transaction,
  );
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final DioClient _dioClient;

  TransactionRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ApiResponseModel<TransactionsResponseModel>> getTransactions(
    TransactionsQuery query,
  ) async {
    final params = query.toQueryParams();

    final response = await _dioClient.get(
      ApiConstants.transactions,
      queryParameters: params,
    );

    return ApiResponseModel<TransactionsResponseModel>.fromJson(
      response.data,
      (json) =>
          TransactionsResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponseModel<TransactionModel>> createTransaction(
    CreateTransactionModel transaction,
  ) async {
    final body = transaction.toJson();

    final response = await _dioClient.post(
      ApiConstants.transactions,
      data: body,
    );

    return ApiResponseModel<TransactionModel>.fromJson(response.data, (json) {
      try {
        // The API response structure is: { "data": { "transaction": { ... } } }
        // But ApiResponseModel.fromJson already extracts the "data" part
        // So json here is: { "transaction": { ... } }

        final transactionData = json as Map<String, dynamic>;

        // Create a new TransactionModel from the extracted data
        return TransactionModel.fromJson(transactionData);
      } catch (e) {
        rethrow;
      }
    });
  }

  @override
  Future<ApiResponseModel<TransactionModel>> updateTransaction(
    int transactionID,
    UpdateTransactionModel transaction,
  ) async {
    final body = transaction.toJson();

    final response = await _dioClient.patch(
      '${ApiConstants.transactions}/$transactionID',
      data: body,
    );

    return ApiResponseModel<TransactionModel>.fromJson(response.data, (json) {
      // Extract the nested transaction data
      final transactionData = json as Map<String, dynamic>;
      if (transactionData.containsKey('transaction')) {
        return TransactionModel.fromJson(
          transactionData['transaction'] as Map<String, dynamic>,
        );
      }
      // Fallback for direct transaction data
      return TransactionModel.fromJson(transactionData);
    });
  }

  @override
  Future<ApiResponseModel<TransactionModel>> updateTransactionStatus(
    int transactionID,
    UpdateTransactionStatusModel transaction,
  ) async {
    final body = transaction.toJson();

    final response = await _dioClient.patch(
      '${ApiConstants.transactions}/$transactionID',
      data: body,
    );

    return ApiResponseModel<TransactionModel>.fromJson(response.data, (json) {
      // Extract the nested transaction data
      final transactionData = json as Map<String, dynamic>;
      if (transactionData.containsKey('transaction')) {
        return TransactionModel.fromJson(
          transactionData['transaction'] as Map<String, dynamic>,
        );
      }
      // Fallback for direct transaction data
      return TransactionModel.fromJson(transactionData);
    });
  }
}
