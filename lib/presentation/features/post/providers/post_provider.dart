import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/usecases/create_post_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_post_usecase.dart';

class PostState {
  final bool isLoading;
  final Failure? failure;
  final String? successMessage;
  final String title;
  final int type; // 1: giveAway, 2: foundItem, 3: findLost, 4: freePost
  final List<String> images;
  final List<NewItem> newItems;
  final List<OldItem> oldItems;

  // Type-specific info fields
  final String description;
  // For foundItem (type 2)
  final String foundLocation;
  final String foundDate;
  // For findLost (type 3)
  final String lostLocation;
  final String lostDate;
  final String reward;
  // Common for foundItem and findLost
  final int categoryID;
  final bool isRepost;
  final int status;

  PostState({
    this.isLoading = false,
    this.failure,
    this.successMessage,
    this.title = '',
    this.type = 1,
    this.images = const [],
    this.newItems = const [],
    this.oldItems = const [],
    this.description = '',
    this.foundLocation = '',
    this.foundDate = '',
    this.lostLocation = '',
    this.lostDate = '',
    this.reward = '',
    this.categoryID = 0,
    this.isRepost = false,
    this.status = 1,
  });

  PostState copyWith({
    bool? isLoading,
    Failure? failure,
    String? successMessage,
    String? title,
    int? type,
    List<String>? images,
    List<NewItem>? newItems,
    List<OldItem>? oldItems,
    String? description,
    String? foundLocation,
    String? foundDate,
    String? lostLocation,
    String? lostDate,
    String? reward,
    int? categoryID,
    bool? isRepost, // Thêm parameter
    int? status,
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      successMessage: successMessage,
      title: title ?? this.title,
      type: type ?? this.type,
      images: images ?? this.images,
      newItems: newItems ?? this.newItems,
      oldItems: oldItems ?? this.oldItems,
      description: description ?? this.description,
      foundLocation: foundLocation ?? this.foundLocation,
      foundDate: foundDate ?? this.foundDate,
      lostLocation: lostLocation ?? this.lostLocation,
      lostDate: lostDate ?? this.lostDate,
      reward: reward ?? this.reward,
      categoryID: categoryID ?? this.categoryID,
      isRepost: isRepost ?? this.isRepost,
      status: status ?? this.status,
    );
  }

  // Helper method to generate info JSON string based on type
  String get infoJson {
    switch (type) {
      case 2: // foundItem
        return jsonEncode(
          FoundItemInfo(
            foundLocation: foundLocation,
            foundDate: foundDate,
          ).toJson(),
        );
      case 3: // findLost
        return jsonEncode(
          FindLostInfo(
            lostLocation: lostLocation,
            lostDate: lostDate,
            reward: reward,
          ).toJson(),
        );
      default:
        return '{}';
    }
  }
}

class PostNotifier extends StateNotifier<PostState> {
  final CreatePostUseCase _createPostUseCase;
  final UpdatePostUseCase _updatePostUseCase;

  PostNotifier(this._createPostUseCase, this._updatePostUseCase)
    : super(PostState());

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateType(int type) {
    state = state.copyWith(type: type);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  // For foundItem (type 2)
  void updateFoundLocation(String location) {
    state = state.copyWith(foundLocation: location);
  }

  void updateFoundDate(String date) {
    state = state.copyWith(foundDate: date);
  }

  // For findLost (type 3)
  void updateLostLocation(String location) {
    state = state.copyWith(lostLocation: location);
  }

  void updateLostDate(String date) {
    state = state.copyWith(lostDate: date);
  }

  void updateReward(String reward) {
    state = state.copyWith(reward: reward);
  }

  // For foundItem and findLost
  void updateCategoryID(int categoryID) {
    state = state.copyWith(categoryID: categoryID);
  }

  void addImage(String base64Image) {
    final updatedImages = [...state.images, base64Image];
    state = state.copyWith(images: updatedImages);
  }

  void removeImage(int index) {
    final updatedImages = [...state.images];
    updatedImages.removeAt(index);
    state = state.copyWith(images: updatedImages);
  }

  void addNewItem(NewItem newItem) {
    final updatedNewItems = [...state.newItems, newItem];
    state = state.copyWith(newItems: updatedNewItems);
  }

  void removeNewItem(int index) {
    final updatedNewItems = [...state.newItems];
    updatedNewItems.removeAt(index);
    state = state.copyWith(newItems: updatedNewItems);
  }

  void addOldItem(OldItem oldItem) {
    final updatedOldItems = [...state.oldItems, oldItem];
    state = state.copyWith(oldItems: updatedOldItems);
  }

  void removeOldItem(int index) {
    final updatedOldItems = [...state.oldItems];
    updatedOldItems.removeAt(index);
    state = state.copyWith(oldItems: updatedOldItems);
  }

  Future<void> createPost() async {
    state = state.copyWith(isLoading: true, failure: null);

    final post = Post(
      title: state.title,
      description: state.description,
      info: state.infoJson, // Use the generated JSON string
      type: state.type,
      categoryID: (state.type == 3) ? state.categoryID : null,
      images: state.images,
      newItems: state.newItems,
      oldItems: state.oldItems,
    );

    final result = await _createPostUseCase(post);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Đăng tin thành công!',
        );
      },
    );
  }

  void clearForm() {
    state = PostState();
  }

  void reset() {
    state = state.copyWith(newItems: [], oldItems: [], images: []);
  }

  void updateIsRepost(bool isRepost) {
    state = state.copyWith(isRepost: isRepost);
  }

  void updateStatus(int status) {
    state = state.copyWith(status: status);
  }

  Future<void> updatePost(
    int postID, {
    String? title,
    String? description,
    List<String>? images,
    bool? isRepost,
    int? status,
  }) async {
    state = state.copyWith(isLoading: true, failure: null);

    final updatePost = UpdatePost(
      title: title,
      description: description,
      images: images,
      isRepost: isRepost,
      status: status,
    );

    final result = await _updatePostUseCase(postID, updatePost);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (message) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Cập nhật bài đăng thành công!',
        );
      },
    );
  }

  Future<void> togglePostStatus(int postID, int currentStatus) async {
    state = state.copyWith(isLoading: true, failure: null);

    // Chuyển đổi status: 3 <-> 4
    final newStatus = currentStatus == 3 ? 4 : 3;

    final updatePost = UpdatePost(
      status: newStatus, // Chỉ gửi status
    );

    final result = await _updatePostUseCase(postID, updatePost);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (message) {
        state = state.copyWith(
          isLoading: false,
          status: newStatus,
          successMessage:
              newStatus == 4 ? 'Đã khóa bài đăng!' : 'Đã mở khóa bài đăng!',
        );
      },
    );
  }

  Future<void> repostPost(int postID, DateTime createdAt) async {
    state = state.copyWith(isLoading: true, failure: null);

    final updatePost = UpdatePost(
      isRepost: true, // Chỉ gửi isRepost
    );

    final result = await _updatePostUseCase(postID, updatePost);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (message) {
        state = state.copyWith(
          isLoading: false,
          isRepost: true,
          successMessage: 'Đã đăng lại bài đăng thành công!',
        );
      },
    );
  }

  Future<void> updatePostTitle(int postID, String title) async {
    await updatePost(postID, title: title);
  }

  Future<void> updatePostDescription(int postID, String description) async {
    await updatePost(postID, description: description);
  }

  Future<void> updatePostImages(int postID, List<String> images) async {
    await updatePost(postID, images: images);
  }

  Future<void> updatePostStatus(int postID, int status) async {
    await updatePost(postID, status: status);
  }
}
