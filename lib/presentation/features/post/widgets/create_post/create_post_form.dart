import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/add_item_dialog.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/common_fields.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/post_type_selection.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/type_specific_fields.dart';
import 'package:trao_doi_do_app/presentation/models/give_away_item.dart';
import 'package:trao_doi_do_app/presentation/models/post_image.dart';
import 'package:trao_doi_do_app/presentation/widgets/image_picker_bottom_sheet.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';

class CreatePostForm extends HookConsumerWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final PostType? preselectedType;

  const CreatePostForm({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    this.preselectedType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key và controllers
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final locationController = useTextEditingController();
    final rewardController = useTextEditingController();
    final timeController = useTextEditingController();

    // State hooks
    final selectedType = useState(preselectedType ?? PostType.giveAway);
    final images = useState<List<PostImage>>([]);
    final giveAwayItems = useState<List<GiveAwayItem>>([]);
    final selectedDateTime = useState<DateTime?>(null);
    final isSubmitting = useState(false);

    // Auto validation states - bắt đầu với disabled, chỉ bật sau khi có lỗi
    final titleAutovalidateMode = useState(AutovalidateMode.disabled);
    final descriptionAutovalidateMode = useState(AutovalidateMode.disabled);
    final locationAutovalidateMode = useState(AutovalidateMode.disabled);
    final categoryAutovalidateMode = useState(AutovalidateMode.disabled);
    final timeAutovalidateMode = useState(AutovalidateMode.disabled);
    final rewardAutovalidateMode = useState(AutovalidateMode.disabled);

    // Thêm state để theo dõi lỗi validation cho images và items
    final imageValidationError = useState<String?>(null);
    final itemValidationError = useState<String?>(null);

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
    Future<void> showImagePickerBottomSheet({
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

    // Helper function để kiểm tra validation cho images
    String? validateImages() {
      if (images.value.isEmpty) {
        return 'Vui lòng thêm ít nhất 1 ảnh cho bài đăng';
      }
      return null;
    }

    // Helper function để kiểm tra validation cho items
    String? validateItems() {
      // Chỉ kiểm tra items cho các loại bài cần món đồ (trừ freePost)
      if (selectedType.value != PostType.freePost && giveAwayItems.value.isEmpty) {
        switch (selectedType.value) {
          case PostType.giveAway:
            return 'Vui lòng thêm ít nhất 1 món đồ để tặng';
          case PostType.foundItem:
            return 'Vui lòng thêm thông tin về món đồ tìm thấy';
          case PostType.findLost:
            return 'Vui lòng thêm thông tin về món đồ bị mất';
          case PostType.wantItem:
            return 'Vui lòng thêm thông tin về món đồ muốn nhận';
          default:
            return 'Vui lòng thêm thông tin về món đồ';
        }
      }
      return null;
    }

    // Helper functions
    Future<void> pickImages() async {
      if (images.value.length >= 4) {
        context.showErrorSnackBar('Chỉ được chọn tối đa 4 ảnh');
        return;
      }

      await showImagePickerBottomSheet(
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
          
          // Xóa lỗi validation khi thêm ảnh thành công
          if (imageValidationError.value != null) {
            imageValidationError.value = null;
          }
        },
      );
    }

    void handleTypeChange(PostType type) {
      ref.read(postProvider.notifier).reset();

      selectedType.value = type;
      // Reset specific fields when changing type
      images.value = [];
      giveAwayItems.value = [];
      selectedDateTime.value = null;
      locationController.clear();
      rewardController.clear();
      timeController.clear();

      // Reset auto validation modes khi đổi type
      titleAutovalidateMode.value = AutovalidateMode.disabled;
      descriptionAutovalidateMode.value = AutovalidateMode.disabled;
      locationAutovalidateMode.value = AutovalidateMode.disabled;
      categoryAutovalidateMode.value = AutovalidateMode.disabled;
      timeAutovalidateMode.value = AutovalidateMode.disabled;
      rewardAutovalidateMode.value = AutovalidateMode.disabled;
      
      // Reset validation errors
      imageValidationError.value = null;
      itemValidationError.value = null;
    }

    void removeImage(String imageId) {
      images.value = images.value.where((img) => img.id != imageId).toList();
      
      // Kiểm tra lại validation sau khi xóa ảnh
      if (images.value.isEmpty && imageValidationError.value == null) {
        imageValidationError.value = validateImages();
      }
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

          // Trigger validation nếu đã có auto validation mode enabled
          if (timeAutovalidateMode.value != AutovalidateMode.disabled) {
            formKey.currentState?.validate();
          }
        }
      }
    }

    // Helper function for add item dialog
    void showAddItemDialog({
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

      showAddItemDialog(
        context: context,
        ref: ref,
        onItemAdded: (item) {
          giveAwayItems.value = [...giveAwayItems.value, item];
          
          // Xóa lỗi validation khi thêm item thành công
          if (itemValidationError.value != null) {
            itemValidationError.value = null;
          }
        },
      );
    }

    void removeGiveAwayItem(String itemId) {
      giveAwayItems.value =
          giveAwayItems.value.where((item) => item.id != itemId).toList();
          
      // Kiểm tra lại validation sau khi xóa item
      if (selectedType.value != PostType.freePost && giveAwayItems.value.isEmpty && itemValidationError.value == null) {
        itemValidationError.value = validateItems();
      }
    }

    Post buildPost() {
      final typeValue = selectedType.value.index;
      final title = titleController.text.trim();
      final description = descriptionController.text.trim();
      final imagesBase64 =
          images.value
              .map((img) => Base64Utils.encodeImageToDataUri(img.imageData!))
              .toList();

      final info = <String, dynamic>{};

      if (typeValue == PostType.findLost.value) {
        info['lostLocation'] = locationController.text.trim();
        info['lostDate'] = selectedDateTime.value?.toIso8601String() ?? '';
        info['reward'] = rewardController.text.trim();
      } else if (typeValue == PostType.foundItem.value) {
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

    // Updated submit function with validation
    Future<void> submitPostWithDetailedConfirmation() async {
      // Reset validation errors
      imageValidationError.value = null;
      itemValidationError.value = null;
      
      // Validate form fields
      final isFormValid = formKey.currentState!.validate();
      
      // Validate images
      final imageError = validateImages();
      if (imageError != null) {
        imageValidationError.value = imageError;
      }
      
      // Validate items
      final itemError = validateItems();
      if (itemError != null) {
        itemValidationError.value = itemError;
      }

      // Nếu form không hợp lệ, bật auto validation
      if (!isFormValid) {
        titleAutovalidateMode.value = AutovalidateMode.onUserInteraction;
        descriptionAutovalidateMode.value = AutovalidateMode.onUserInteraction;
        locationAutovalidateMode.value = AutovalidateMode.onUserInteraction;
        categoryAutovalidateMode.value = AutovalidateMode.onUserInteraction;
        timeAutovalidateMode.value = AutovalidateMode.onUserInteraction;
        rewardAutovalidateMode.value = AutovalidateMode.onUserInteraction;
      }

      // Nếu có bất kỳ lỗi nào, dừng lại và scroll đến lỗi đầu tiên
      if (!isFormValid || imageError != null || itemError != null) {
        // Scroll to first error (có thể implement scroll behavior ở đây)
        return;
      }

      // Build detailed confirmation content
      final typeDisplayName = selectedType.value.label;
      final title = titleController.text.trim();
      final description = descriptionController.text.trim();
      final imageCount = images.value.length;
      final itemCount = giveAwayItems.value.length;

      String confirmationContent =
          'Thông tin bài đăng:\n\n'
          '• Loại bài: $typeDisplayName\n'
          '• Tiêu đề: $title\n'
          '• Mô tả: ${description.length > 50 ? '${description.substring(0, 50)}...' : description}\n'
          '• Số ảnh: $imageCount\n';

      if (selectedType.value != PostType.freePost && itemCount > 0) {
        confirmationContent += '• Số món đồ: $itemCount\n';
      }

      if (selectedType.value == PostType.findLost ||
          selectedType.value == PostType.foundItem) {
        final location = locationController.text.trim();
        if (location.isNotEmpty) {
          confirmationContent += '• Địa điểm: $location\n';
        }
        if (selectedDateTime.value != null) {
          confirmationContent +=
              '• Thời gian: ${TimeUtils.formatAbsolute(selectedDateTime.value!)}\n';
        }
        if (selectedType.value == PostType.findLost &&
            rewardController.text.trim().isNotEmpty) {
          confirmationContent +=
              '• Phần thưởng: ${rewardController.text.trim()}\n';
        }
      }

      confirmationContent +=
          '\nBài đăng sẽ được gửi đi kiểm duyệt trước khi hiển thị công khai.';

      // Show detailed confirmation dialog
      final confirmed = await context.showConfirmDialog(
        title: 'Xác nhận đăng bài',
        content: confirmationContent,
        confirmText: 'Đăng bài',
        cancelText: 'Kiểm tra lại',
      );

      if (confirmed != true) return;

      final useCase = ref.read(createPostUseCaseProvider);
      final post = buildPost();

      isSubmitting.value = true;

      final result = await useCase(post);

      result.fold((failure) => context.showErrorSnackBar(failure.message), (_) {
        ref.read(postProvider.notifier).reset();
        context.showSuccessSnackBar(
          'Tạo bài thành công, vui lòng đợi kiểm duyệt!',
        );
        context.pop();
        context.pushNamed(RouteNames.myPosts);
      });

      isSubmitting.value = false;
    }

    // Validation trigger functions
    void onLocationChanged() {
      if (locationAutovalidateMode.value != AutovalidateMode.disabled) {
        formKey.currentState?.validate();
      }
    }

    void onRewardChanged() {
      if (rewardAutovalidateMode.value != AutovalidateMode.disabled) {
        formKey.currentState?.validate();
      }
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

            // Common Fields với auto validation modes
            CommonFields(
              titleController: titleController,
              descriptionController: descriptionController,
              images: images.value,
              onPickImages: pickImages,
              onRemoveImage: removeImage,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
              titleAutovalidateMode: titleAutovalidateMode.value,
              descriptionAutovalidateMode: descriptionAutovalidateMode.value,
              // Thêm validation error cho images
              imageValidationError: imageValidationError.value,
            ),

            // Type-specific Fields
            TypeSpecificFields(
              selectedType: selectedType.value,
              locationController: locationController,
              timeController: timeController,
              rewardController: rewardController,
              onSelectDateTime: selectDateTime,
              giveAwayItems: giveAwayItems.value,
              onAddGiveAwayItem: addGiveAwayItem,
              onRemoveGiveAwayItem: removeGiveAwayItem,
              isSubmitting: isSubmitting.value,
              onSubmit: submitPostWithDetailedConfirmation,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
              // Auto validation modes cho type-specific fields
              locationAutovalidateMode: locationAutovalidateMode.value,
              categoryAutovalidateMode: categoryAutovalidateMode.value,
              timeAutovalidateMode: timeAutovalidateMode.value,
              rewardAutovalidateMode: rewardAutovalidateMode.value,
              // Callback functions cho real-time validation
              onLocationChanged: onLocationChanged,
              onRewardChanged: onRewardChanged,
              // Thêm validation error cho items
              itemValidationError: itemValidationError.value,
            ),

            SizedBox(height: isTablet ? 32 : 24),
          ],
        ),
      ),
    );
  }
}