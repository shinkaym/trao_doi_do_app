import 'package:trao_doi_do_app/data/models/transaction_model.dart';
import 'package:trao_doi_do_app/domain/entities/response/transaction_response.dart';

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
          (json['transactions'] as List? ?? [])
              .map(
                (item) =>
                    TransactionModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      totalPage: json['totalPage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactions':
          transactions.map((transaction) => transaction.toJson()).toList(),
      'totalPage': totalPage,
    };
  }

  // Convert to domain entity
  TransactionsResponse toEntity() {
    return TransactionsResponse(
      transactions:
          transactions.map((transaction) => transaction.toEntity()).toList(),
      totalPage: totalPage,
    );
  }

  // Create from domain entity
  factory TransactionsResponseModel.fromEntity(TransactionsResponse entity) {
    return TransactionsResponseModel(
      transactions:
          entity.transactions
              .map((transaction) => TransactionModel.fromEntity(transaction))
              .toList(),
      totalPage: entity.totalPage,
    );
  }
}

class CreateTransactionRequestModel {
  final int interestID;
  final List<CreateTransactionItemRequestModel> items;

  const CreateTransactionRequestModel({
    required this.interestID,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'interestID': interestID,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory CreateTransactionRequestModel.fromJson(Map<String, dynamic> json) {
    return CreateTransactionRequestModel(
      interestID: json['interestID'] ?? 0,
      items:
          (json['items'] as List? ?? [])
              .map(
                (item) => CreateTransactionItemRequestModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}

class CreateTransactionItemRequestModel {
  final int postItemID;
  final int quantity;

  const CreateTransactionItemRequestModel({
    required this.postItemID,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {'postItemID': postItemID, 'quantity': quantity};
  }

  factory CreateTransactionItemRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CreateTransactionItemRequestModel(
      postItemID: json['postItemID'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }
}

// ===== UPDATE TRANSACTION REQUEST MODELS =====

class UpdateTransactionRequestModel {
  final List<UpdateTransactionItemRequestModel> items;
  final int status;

  const UpdateTransactionRequestModel({
    required this.items,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
    };
  }

  factory UpdateTransactionRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateTransactionRequestModel(
      items:
          (json['items'] as List? ?? [])
              .map(
                (item) => UpdateTransactionItemRequestModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      status: json['status'] ?? 1,
    );
  }
}

class UpdateTransactionItemRequestModel {
  final int postItemID;
  final int quantity;
  final int transactionID;

  const UpdateTransactionItemRequestModel({
    required this.postItemID,
    required this.quantity,
    required this.transactionID,
  });

  Map<String, dynamic> toJson() {
    return {
      'postItemID': postItemID,
      'quantity': quantity,
      'transactionID': transactionID,
    };
  }

  factory UpdateTransactionItemRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UpdateTransactionItemRequestModel(
      postItemID: json['postItemID'] ?? 0,
      quantity: json['quantity'] ?? 0,
      transactionID: json['transactionID'] ?? 0,
    );
  }
}

class UpdateTransactionStatusRequestModel {
  final int status;

  const UpdateTransactionStatusRequestModel({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status};
  }

  factory UpdateTransactionStatusRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UpdateTransactionStatusRequestModel(status: json['status'] ?? 1);
  }
}
