
import 'package:trao_doi_do_app/domain/entities/item.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.categoryID,
    required super.name,
    required super.description,
    super.image,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as int,
      categoryID: json['categoryID'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryID': categoryID,
      'name': name,
      'description': description,
      'image': image,
    };
  }

  static List<ItemModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class ItemsResponseModel {
  final List<ItemModel> items;
  final int totalPage;

  ItemsResponseModel({required this.items, required this.totalPage});

  factory ItemsResponseModel.fromJson(Map<String, dynamic> json) {
    return ItemsResponseModel(
      items: ItemModel.fromJsonList(json['items'] as List<dynamic>),
      totalPage: json['totalPage'] as int,
    );
  }
}
