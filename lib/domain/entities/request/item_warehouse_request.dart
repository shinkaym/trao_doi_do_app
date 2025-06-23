import 'package:equatable/equatable.dart';

class ClaimItemRequest extends Equatable {
  final int itemID;
  final int quantity;

  const ClaimItemRequest({
    required this.itemID,
    required this.quantity,
  });

  @override
  List<Object?> get props => [itemID, quantity];
}
