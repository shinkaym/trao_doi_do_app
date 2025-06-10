import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/domain/usecases/create_post_usecase.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/post_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/add_item_dialog.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/common_fields.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/post_type_selection.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/type_specific_fields.dart';
import 'package:trao_doi_do_app/presentation/models/give_away_item.dart';
import 'package:trao_doi_do_app/presentation/models/post_image.dart';
import 'package:trao_doi_do_app/presentation/providers/category_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/item_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/image_picker_bottom_sheet.dart';

class CreatePostForm extends HookConsumerWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const CreatePostForm({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key và controllers
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final locationController = useTextEditingController();
    final categoryController = useTextEditingController();
    final rewardController = useTextEditingController();
    final timeController = useTextEditingController();

    // State hooks
    final selectedType = useState(CreatePostType.giveAway);
    final images = useState<List<PostImage>>([]);
    final giveAwayItems = useState<List<GiveAwayItem>>([]);
    final selectedDateTime = useState<DateTime?>(null);
    final isSubmitting = useState(false);

    // Image picker
    final picker = useMemoized(() => ImagePicker());

    // Load data when screen initializes
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(postProvider.notifier).reset();
        ref.read(categoryProvider.notifier).getCategories();
        ref.read(itemsListProvider.notifier).loadItems(refresh: true);
      });
      return null;
    }, []);

    // Helper function for image picker bottom sheet
    Future<void> _showImagePickerBottomSheet({
      required BuildContext context,
      required ImagePicker picker,
      required Function(Uint8List bytes, double sizeInMB) onImagePicked,
      String title = 'Chọn ảnh',
    }) async {
      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder:
            (_) => ImagePickerBottomSheet(
              picker: picker,
              title: title,
              onImageSelected: (file) async {
                final bytes = await file.readAsBytes();
                final sizeInMB = bytes.lengthInBytes / (1024 * 1024);
                onImagePicked(bytes, sizeInMB);
              },
            ),
      );
    }

    // Helper functions
    Future<void> pickImages() async {
      if (images.value.length >= 4) {
        context.showErrorSnackBar('Chỉ được chọn tối đa 4 ảnh');
        return;
      }

      await _showImagePickerBottomSheet(
        context: context,
        picker: picker,
        title: 'Chọn ảnh bài đăng',
        onImagePicked: (bytes, sizeInMB) {
          if (sizeInMB > 5) {
            context.showErrorSnackBar('Ảnh vượt quá 5MB');
            return;
          }

          final newImage = PostImage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imageData: bytes,
            sizeInMB: sizeInMB,
          );

          images.value = [...images.value, newImage];
        },
      );
    }

    void handleTypeChange(CreatePostType type) {
      ref.read(postProvider.notifier).reset();

      selectedType.value = type;
      // Reset specific fields when changing type
      images.value = [];
      giveAwayItems.value = [];
      selectedDateTime.value = null;
      locationController.clear();
      categoryController.clear();
      rewardController.clear();
      timeController.clear();
    }

    void removeImage(String imageId) {
      images.value = images.value.where((img) => img.id != imageId).toList();
    }

    Future<void> selectDateTime() async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now(),
      );

      if (date != null) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (time != null) {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          selectedDateTime.value = dateTime;
          timeController.text = TimeUtils.formatAbsolute(dateTime);
        }
      }
    }

    // Helper function for add item dialog
    void _showAddItemDialog({
      required BuildContext context,
      required WidgetRef ref,
      required Function(GiveAwayItem) onItemAdded,
    }) {
      showDialog(
        context: context,
        builder: (_) => AddItemDialog(onItemAdded: onItemAdded, ref: ref),
      );
    }

    void addGiveAwayItem() {
      if (giveAwayItems.value.length >= 4) {
        context.showErrorSnackBar('Chỉ được thêm tối đa 4 món đồ');
        return;
      }

      _showAddItemDialog(
        context: context,
        ref: ref,
        onItemAdded: (item) {
          giveAwayItems.value = [...giveAwayItems.value, item];
        },
      );
    }

    void removeGiveAwayItem(String itemId) {
      giveAwayItems.value =
          giveAwayItems.value.where((item) => item.id != itemId).toList();
    }

    Post buildPost() {
      final typeValue = selectedType.value.typeValue;
      final title = titleController.text.trim();
      final description = descriptionController.text.trim();
      final imagesBase64 =
          images.value.map((img) => base64Encode(img.imageData!)).toList();

      final info = <String, dynamic>{};

      if (selectedType.value == CreatePostType.findLost) {
        info['lostLocation'] = locationController.text.trim();
        info['lostDate'] = selectedDateTime.value?.toIso8601String() ?? '';
        info['reward'] = rewardController.text.trim();
        info['category'] = categoryController.text.trim();
      } else if (selectedType.value == CreatePostType.foundItem) {
        info['foundLocation'] = locationController.text.trim();
        info['foundDate'] = selectedDateTime.value?.toIso8601String() ?? '';
      }

      final postState = ref.watch(postProvider);

      return Post(
        title: title,
        description: description,
        type: typeValue,
        info: jsonEncode(info),
        images: imagesBase64,
        newItems: postState.newItems,
        oldItems: postState.oldItems,
      );
    }

    Future<void> submitPost() async {
      if (!formKey.currentState!.validate()) return;

      final useCase = ref.read(createPostUseCaseProvider);
      final post = buildPost();

      isSubmitting.value = true;

      final result = await useCase(post);

      result.fold((failure) => context.showErrorSnackBar(failure.message), (_) {
        ref.read(postProvider.notifier).reset();
        context.showSuccessSnackBar('Đăng bài thành công!');
        context.pop();
      });

      isSubmitting.value = false;
    }

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Type Selection
            PostTypeSelection(
              selectedType: selectedType.value,
              onTypeChanged: handleTypeChange,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
            ),
            SizedBox(height: isTablet ? 32 : 24),

            // Common Fields
            CommonFields(
              titleController: titleController,
              descriptionController: descriptionController,
              images: images.value,
              onPickImages: pickImages,
              onRemoveImage: removeImage,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
            ),

            // Type-specific Fields
            TypeSpecificFields(
              selectedType: selectedType.value,
              locationController: locationController,
              timeController: timeController,
              rewardController: rewardController,
              categoryController: categoryController,
              onSelectDateTime: selectDateTime,
              giveAwayItems: giveAwayItems.value,
              onAddGiveAwayItem: addGiveAwayItem,
              onRemoveGiveAwayItem: removeGiveAwayItem,
              isSubmitting: isSubmitting.value,
              onSubmit: submitPost,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
            ),

            SizedBox(height: isTablet ? 32 : 24),
          ],
        ),
      ),
    );
  }
}
