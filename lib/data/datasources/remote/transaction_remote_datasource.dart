import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final DioClient _dioClient;

  TransactionRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ApiResponseModel<TransactionsResponseModel>> getTransactions(
    TransactionsQuery query,
  ) async {
    final params = query.toQueryParams();
    print('📥 Transaction params: $params');

    final response = await _dioClient.get(
      ApiConstants.transactions,
      queryParameters: params,
    );

    // ✅ Print raw JSON response
    print(
      '📥 Transaction JSON response:\n${const JsonEncoder.withIndent('  ').convert(response.data)}',
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
    // ✅ Display formatted JSON body
    print(
      '📤 Create Transaction JSON:\n${const JsonEncoder.withIndent('  ').convert(body)}',
    );

    final response = await _dioClient.post(
      ApiConstants.transactions,
      data: body,
    );

    // ✅ Print response
    print(
      '📥 Create Transaction Response:\n${const JsonEncoder.withIndent('  ').convert(response.data)}',
    );

    return ApiResponseModel<TransactionModel>.fromJson(
      response.data,
      (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponseModel<TransactionModel>> updateTransaction(
    int transactionID,
    UpdateTransactionModel transaction,
  ) async {
    final body = transaction.toJson();
    // ✅ Display formatted JSON body
    print(
      '📤 Update Transaction JSON (ID: $transactionID):\n${const JsonEncoder.withIndent('  ').convert(body)}',
    );

    final response = await _dioClient.patch(
      '${ApiConstants.transactions}/$transactionID',
      data: body,
    );

    // ✅ Print response
    print(
      '📥 Update Transaction Response:\n${const JsonEncoder.withIndent('  ').convert(response.data)}',
    );

    return ApiResponseModel<TransactionModel>.fromJson(
      response.data,
      (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return TransactionRemoteDataSourceImpl(dioClient);
    });
