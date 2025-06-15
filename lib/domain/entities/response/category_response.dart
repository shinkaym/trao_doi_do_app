import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';

class CategoriesResponse extends Equatable {
  final List<Category> categories;

  const CategoriesResponse({required this.categories});

  @override
  List<Object?> get props => [categories];
}
