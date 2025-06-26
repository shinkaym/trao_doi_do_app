import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/usecases/get_posts_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/params/post_query.dart';

class SearchSuggestionsState {
  final bool isLoading;
  final List<Post> suggestions;
  final String query;
  final Failure? failure;

  SearchSuggestionsState({
    this.isLoading = false,
    this.suggestions = const [],
    this.query = '',
    this.failure,
  });

  SearchSuggestionsState copyWith({
    bool? isLoading,
    List<Post>? suggestions,
    String? query,
    Failure? failure,
  }) {
    return SearchSuggestionsState(
      isLoading: isLoading ?? this.isLoading,
      suggestions: suggestions ?? this.suggestions,
      query: query ?? this.query,
      failure: failure,
    );
  }
}

class SearchSuggestionsNotifier extends StateNotifier<SearchSuggestionsState> {
  final GetPostsUseCase _getPostsUseCase;
  Timer? _debounceTimer;

  SearchSuggestionsNotifier(this._getPostsUseCase)
    : super(SearchSuggestionsState());

  void searchWithDebounce(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = SearchSuggestionsState();
      return;
    }

    state = state.copyWith(isLoading: true, query: query.trim(), failure: null);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      state = SearchSuggestionsState();
      return;
    }

    final searchQuery = PostsQuery(
      search: query,
      limit: 5, // Chỉ lấy 5 kết quả gợi ý
      page: 1,
    );

    final result = await _getPostsUseCase(searchQuery);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (postsResult) =>
          state = state.copyWith(
            isLoading: false,
            suggestions: postsResult.posts,
          ),
    );
  }

  void clear() {
    _debounceTimer?.cancel();
    state = SearchSuggestionsState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
