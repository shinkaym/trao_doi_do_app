import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';

class CategoriesResult {
  final List<Category> categories;

  const CategoriesResult({required this.categories});
}

abstract class CategoryRepository {
  Future<Either<Failure, CategoriesResult>> getCategories();
}
