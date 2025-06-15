import 'package:equatable/equatable.dart';

class CreateTransactionRequest extends Equatable {
  final int interestID;
  final List<CreateTransactionItemRequest> items;

  const CreateTransactionRequest({
    required this.interestID,
    required this.items,
  });

  @override
  List<Object?> get props => [interestID, items];
}

class CreateTransactionItemRequest extends Equatable {
  final int postItemID;
  final int quantity;

  const CreateTransactionItemRequest({
    required this.postItemID,
    required this.quantity,
  });

  @override
  List<Object?> get props => [postItemID, quantity];
}

class UpdateTransactionRequest extends Equatable {
  final List<UpdateTransactionItemRequest> items;
  final int status;

  const UpdateTransactionRequest({required this.items, required this.status});

  @override
  List<Object?> get props => [items, status];
}

class UpdateTransactionItemRequest extends Equatable {
  final int postItemID;
  final int quantity;
  final int transactionID;

  const UpdateTransactionItemRequest({
    required this.postItemID,
    required this.quantity,
    required this.transactionID,
  });

  @override
  List<Object?> get props => [postItemID, quantity, transactionID];
}

class UpdateTransactionStatusRequest extends Equatable {
  final int status;

  const UpdateTransactionStatusRequest({required this.status});

  @override
  List<Object?> get props => [status];
}
