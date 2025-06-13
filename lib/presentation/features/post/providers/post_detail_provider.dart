import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/models/response/post_response_model.dart';
import 'package:trao_doi_do_app/domain/usecases/get_post_detail_usecase.dart';

class PostDetailState {
  final bool isLoading;
  final PostDetailModel? post;
  final Failure? failure;

  PostDetailState({this.isLoading = false, this.post, this.failure});

  PostDetailState copyWith({
    bool? isLoading,
    PostDetailModel? post,
    Failure? failure,
  }) {
    return PostDetailState(
      isLoading: isLoading ?? this.isLoading,
      post: post ?? this.post,
      failure: failure,
    );
  }
}

class PostDetailNotifier extends StateNotifier<PostDetailState> {
  final GetPostDetailUseCase _getPostDetailUseCase;

  PostDetailNotifier(this._getPostDetailUseCase) : super(PostDetailState());

  Future<void> getPostDetail(String slug) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    final result = await _getPostDetailUseCase(slug);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (post) => state = state.copyWith(isLoading: false, post: post),
    );
  }

  void clearPost() {
    state = PostDetailState();
  }
}

final postDetailProvider =
    StateNotifierProvider<PostDetailNotifier, PostDetailState>((ref) {
      final getPostDetailUseCase = ref.watch(getPostDetailUseCaseProvider);
      return PostDetailNotifier(getPostDetailUseCase);
    });
