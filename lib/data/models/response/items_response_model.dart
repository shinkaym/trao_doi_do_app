import 'package:trao_doi_do_app/data/models/item_model.dart';

class ItemsResponseModel {
  final List<ItemModel> items;
  final int totalPage;

  const ItemsResponseModel({required this.items, required this.totalPage});

  factory ItemsResponseModel.fromJson(Map<String, dynamic> json) {
    return ItemsResponseModel(
      items:
          (json['items'] as List<dynamic>)
              .map((item) => ItemModel.fromJson(item as Map<String, dynamic>))
              .toList(),
      totalPage: json['totalPage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalPage': totalPage,
    };
  }
}
