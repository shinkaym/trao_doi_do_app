import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';

class PostsResponse extends Equatable {
  final List<Post> posts;
  final int totalPage;

  const PostsResponse({
    required this.posts,
    required this.totalPage,
  });

  @override
  List<Object?> get props => [posts, totalPage];
}

class PostDetailResponse extends Equatable {
  final PostDetail post;

  const PostDetailResponse({required this.post});

  @override
  List<Object?> get props => [post];
}