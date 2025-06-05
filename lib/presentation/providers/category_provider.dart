import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';
import 'package:trao_doi_do_app/domain/usecases/get_categories_usecase.dart';

class CategoryState {
  final bool isLoading;
  final List<Category> categories;
  final Failure? failure;

  CategoryState({
    this.isLoading = false,
    this.categories = const [],
    this.failure,
  });

  CategoryState copyWith({
    bool? isLoading,
    List<Category>? categories,
    Failure? failure,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      failure: failure,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoryNotifier(this._getCategoriesUseCase) : super(CategoryState());

  Future<void> getCategories() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    final result = await _getCategoriesUseCase();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (categoriesResult) =>
          state = state.copyWith(
            isLoading: false,
            categories: categoriesResult.categories,
          ),
    );
  }

  void refresh() {
    getCategories();
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) {
    final getCategoriesUseCase = ref.watch(getCategoriesUseCaseProvider);
    return CategoryNotifier(getCategoriesUseCase);
  },
);
