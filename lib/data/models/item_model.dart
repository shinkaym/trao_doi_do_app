import 'package:trao_doi_do_app/domain/entities/item.dart';

class ItemModel {
  final int id;
  final int categoryID;
  final String name;
  final String description;
  final String? image;

  const ItemModel({
    required this.id,
    required this.categoryID,
    required this.name,
    required this.description,
    this.image,
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

  Item toEntity() {
    return Item(
      id: id,
      categoryID: categoryID,
      name: name,
      description: description,
      image: image,
    );
  }

  factory ItemModel.fromEntity(Item item) {
    return ItemModel(
      id: item.id,
      categoryID: item.categoryID,
      name: item.name,
      description: item.description,
      image: item.image,
    );
  }
}
