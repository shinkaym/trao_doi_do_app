import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/repositories_impl/post_repository_impl.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository _repository;

  CreatePostUseCase(this._repository);

  Future<Either<Failure, void>> call(Post post) async {
    // Common validation
    if (post.title.trim().isEmpty) {
      return const Left(ValidationFailure('Tiêu đề không được để trống'));
    }

    // Validate based on post type
    final validationResult = _validateByType(post);
    if (validationResult != null) {
      return Left(validationResult);
    }

    return await _repository.createPost(post);
  }

  ValidationFailure? _validateByType(Post post) {
    try {
      final infoJson = jsonDecode(post.info);
      final description = infoJson['description'] as String?;

      if (description == null || description.trim().isEmpty) {
        return const ValidationFailure('Mô tả không được để trống');
      }

      switch (post.type) {
        case 1: // giveAway
          return _validateGiveAway(post);
        case 2: // foundItem
          return _validateFoundItem(post, infoJson);
        case 3: // findLost
          return _validateFindLost(post, infoJson);
        case 4: // freePost
          return _validateFreePost(post);
        default:
          return const ValidationFailure('Loại bài đăng không hợp lệ');
      }
    } catch (e) {
      return const ValidationFailure('Thông tin bài đăng không hợp lệ');
    }
  }

  ValidationFailure? _validateGiveAway(Post post) {
    if (post.newItems.isEmpty && post.oldItems.isEmpty) {
      return const ValidationFailure('Phải chọn ít nhất một món đồ');
    }

    // Validate newItems
    for (final item in post.newItems) {
      if (item.name.trim().isEmpty) {
        return const ValidationFailure('Tên món đồ mới không được để trống');
      }
      if (item.categoryID <= 0) {
        return const ValidationFailure('Phải chọn danh mục cho món đồ mới');
      }
      if (item.quantity <= 0) {
        return const ValidationFailure('Số lượng món đồ mới phải lớn hơn 0');
      }
    }

    // Validate oldItems
    for (final item in post.oldItems) {
      if (item.itemID <= 0) {
        return const ValidationFailure('ID món đồ cũ không hợp lệ');
      }
      if (item.quantity <= 0) {
        return const ValidationFailure('Số lượng món đồ cũ phải lớn hơn 0');
      }
    }

    return null;
  }

  ValidationFailure? _validateFoundItem(
    Post post,
    Map<String, dynamic> infoJson,
  ) {
    if (post.images.isEmpty) {
      return const ValidationFailure('Phải có ít nhất một hình ảnh');
    }

    final foundLocation = infoJson['foundLocation'] as String?;
    final foundDate = infoJson['foundDate'] as String?;
    final categoryID = infoJson['categoryID'] as int?;

    if (foundLocation == null || foundLocation.trim().isEmpty) {
      return const ValidationFailure('Địa điểm nhặt được không được để trống');
    }

    if (foundDate == null || foundDate.trim().isEmpty) {
      return const ValidationFailure('Ngày nhặt được không được để trống');
    }

    if (categoryID == null || categoryID <= 0) {
      return const ValidationFailure('Phải chọn danh mục cho món đồ nhặt được');
    }

    return null;
  }

  ValidationFailure? _validateFindLost(
    Post post,
    Map<String, dynamic> infoJson,
  ) {
    final lostLocation = infoJson['lostLocation'] as String?;
    final lostDate = infoJson['lostDate'] as String?;
    final categoryID = infoJson['categoryID'] as int?;
    final reward = infoJson['reward'] as String?;

    if (lostLocation == null || lostLocation.trim().isEmpty) {
      return const ValidationFailure('Địa điểm thất lạc không được để trống');
    }

    if (lostDate == null || lostDate.trim().isEmpty) {
      return const ValidationFailure('Ngày thất lạc không được để trống');
    }

    if (categoryID == null || categoryID <= 0) {
      return const ValidationFailure('Phải chọn danh mục cho món đồ thất lạc');
    }

    if (reward == null || reward.trim().isEmpty) {
      return const ValidationFailure(
        'Thông tin phần thưởng không được để trống',
      );
    }

    return null;
  }

  ValidationFailure? _validateFreePost(Post post) {
    // FreePost chỉ cần description, không bắt buộc images
    return null;
  }
}

final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return CreatePostUseCase(repository);
});
