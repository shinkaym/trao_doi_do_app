import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/usecases/get_post_by_id_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_post_detail_usecase.dart';

class PostDetailState {
  final bool isLoading;
  final PostDetail? post;
  final Failure? failure;

  PostDetailState({this.isLoading = false, this.post, this.failure});

  PostDetailState copyWith({
    bool? isLoading,
    PostDetail? post,
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
  final GetPostByIDUseCase _getPostByIDUseCase;

  PostDetailNotifier(this._getPostDetailUseCase, this._getPostByIDUseCase)
    : super(PostDetailState());

  Future<void> getPostDetail({String? slug, int? postID}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    final result =
        slug != null
            ? await _getPostDetailUseCase(slug)
            : await _getPostByIDUseCase(postID!);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (postDetailResponse) {
        final postDetail = postDetailResponse.post;
        state = state.copyWith(isLoading: false, post: postDetail);
      },
    );
  }

  void clearPost() {
    state = PostDetailState();
  }
}
