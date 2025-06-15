import 'package:trao_doi_do_app/domain/entities/category.dart';

class CategoryModel {
  final int id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  Category toEntity() {
    return Category(id: id, name: name);
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(id: category.id, name: category.name);
  }
}
