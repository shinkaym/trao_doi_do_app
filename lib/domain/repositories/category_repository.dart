import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/response/category_response.dart';

abstract class CategoryRepository {
  Future<Either<Failure, CategoriesResponse>> getCategories();
}
