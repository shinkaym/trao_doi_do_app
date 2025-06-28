import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/all_users_bottom_sheet.dart';

class PostDetailHelpers {
  PostDetailHelpers._();

  /// Kiểm tra xem user hiện tại có phải là tác giả bài đăng không
  static bool isPostAuthor(PostDetail post, dynamic currentUser) {
    if (currentUser == null) return false;
    return post.authorID == currentUser.id;
  }

  /// Kiểm tra xem user có quan tâm bài đăng không
  static bool isUserInterested(List<PostInterest> interests, int? userID) {
    if (userID == null) return false;
    return interests.any((interest) => interest.userID == userID);
  }

  /// Lấy ID của interest của user
  static int? getUserInterestId(List<PostInterest> interests, int? userID) {
    if (userID == null) return null;
    try {
      final userInterest = interests.firstWhere(
        (interest) => interest.userID == userID,
      );
      return userInterest.id;
    } catch (e) {
      return null;
    }
  }

  static void showAllUsersBottomSheet(
    BuildContext context,
    List<PostInterest> interests,
    bool isPostOwner,
  ) {
    if (interests.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AllUsersBottomSheet(interests: interests),
    );
  }
}
