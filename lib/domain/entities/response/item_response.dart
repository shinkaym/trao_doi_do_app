import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/item.dart';

class ItemsResponse extends Equatable {
  final List<Item> items;
  final int totalPage;

  const ItemsResponse({required this.items, required this.totalPage});

  @override
  List<Object?> get props => [items, totalPage];
}
