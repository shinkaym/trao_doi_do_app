import 'package:flutter_debouncer/flutter_debouncer.dart';
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
  final Debouncer _debouncer;

  SearchSuggestionsNotifier(this._getPostsUseCase)
    : _debouncer = Debouncer(),
      super(SearchSuggestionsState());

  void searchWithDebounce(String query) {
    if (query.trim().isEmpty) {
      state = SearchSuggestionsState();
      return;
    }

    state = state.copyWith(isLoading: true, query: query.trim(), failure: null);

    _debouncer.debounce(
      duration: const Duration(milliseconds: 500),
      onDebounce: () {
        _performSearch(query.trim());
      },
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      state = SearchSuggestionsState();
      return;
    }

    final searchQuery = PostsQuery(
      search: query,
      limit: 7, 
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
    _debouncer.cancel();
    state = SearchSuggestionsState();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}
