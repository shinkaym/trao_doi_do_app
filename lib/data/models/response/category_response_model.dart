import 'package:trao_doi_do_app/data/models/category_model.dart';
import 'package:trao_doi_do_app/domain/entities/response/category_response.dart';

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

  CategoriesResponse toEntity() {
    return CategoriesResponse(
      categories: categories.map((e) => e.toEntity()).toList(),
    );
  }

  factory CategoriesResponseModel.fromEntity(CategoriesResponse entity) {
    return CategoriesResponseModel(
      categories:
          entity.categories.map((e) => CategoryModel.fromEntity(e)).toList(),
    );
  }
}
