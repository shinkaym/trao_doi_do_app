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
