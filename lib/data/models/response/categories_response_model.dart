import 'package:trao_doi_do_app/data/models/category_model.dart';

class CategoriesResponseModel {
  final List<CategoryModel> categories;

  const CategoriesResponseModel({required this.categories});

  factory CategoriesResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoriesResponseModel(
      categories:
          (json['categories'] as List<dynamic>)
              .map(
                (category) =>
                    CategoryModel.fromJson(category as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }
}
