import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/usecases/create_post_usecase.dart';
import 'package:trao_doi_do_app/presentation/providers/category_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/item_provider.dart';

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
  final String category;
  // Common for foundItem and findLost
  final int categoryID;

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
    this.category = '',
    this.categoryID = 0,
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
    String? category,
    int? categoryID,
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
      category: category ?? this.category,
      categoryID: categoryID ?? this.categoryID,
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
            category: category,
          ).toJson(),
        );
      default:
        return '{}';
    }
  }
}

class PostNotifier extends StateNotifier<PostState> {
  final CreatePostUseCase _createPostUseCase;
  final Ref _ref;

  PostNotifier(this._createPostUseCase, this._ref) : super(PostState());

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

  void updateCategory(String category) {
    state = state.copyWith(category: category);
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

  Future<void> loadCategories() async {
    await _ref.read(categoryProvider.notifier).getCategories();
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
        _ref.read(itemsListProvider.notifier).loadItems(refresh: true);
      },
    );
  }

  void clearForm() {
    state = PostState();
  }

  void reset() {
  state = state.copyWith(
    newItems: [],
    oldItems: [],
    images: [],
  );
}
}

final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  final createPostUseCase = ref.watch(createPostUseCaseProvider);
  return PostNotifier(createPostUseCase, ref);
});
