import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:trao_doi_do_app/presentation/providers/category_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/item_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/image_picker_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class GiveAwayItem {
  final String id;
  final String name;
  final String? description;
  final Uint8List? imageData;
  final String? imagePath;
  final int quantity;
  final bool isFromPreset;
  final int? categoryId;

  const GiveAwayItem({
    required this.id,
    required this.name,
    this.description,
    this.imageData,
    this.imagePath,
    this.quantity = 1,
    this.isFromPreset = false,
    this.categoryId,
  });

  GiveAwayItem copyWith({
    String? id,
    String? name,
    String? description,
    Uint8List? imageData,
    String? imagePath,
    int? quantity,
    bool? isFromPreset,
    int? categoryId,
  }) {
    return GiveAwayItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageData: imageData ?? this.imageData,
      imagePath: imagePath ?? this.imagePath,
      quantity: quantity ?? this.quantity,
      isFromPreset: isFromPreset ?? this.isFromPreset,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

// Model cho hình ảnh
class PostImage {
  final String id;
  final Uint8List? imageData;
  final String? imagePath;
  final double sizeInMB;

  const PostImage({
    required this.id,
    this.imageData,
    this.imagePath,
    required this.sizeInMB,
  });

  PostImage copyWith({
    String? id,
    Uint8List? imageData,
    String? imagePath,
    double? sizeInMB,
  }) {
    return PostImage(
      id: id ?? this.id,
      imageData: imageData ?? this.imageData,
      imagePath: imagePath ?? this.imagePath,
      sizeInMB: sizeInMB ?? this.sizeInMB,
    );
  }
}

class CreatePostScreen extends HookConsumerWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Watch auth state
    final authState = ref.watch(authProvider);

    // If not logged in, show login prompt
    if (!authState.isLoggedIn) {
      return SmartScaffold(
        title: 'Đăng bài',
        appBarType: AppBarType.standard,
        showBackButton: true,
        body: _buildLoginPrompt(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          context: context,
        ),
      );
    }

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
        context.showSuccessSnackBar('Đăng bài thành công!');
        Navigator.pop(context);
      });

      isSubmitting.value = false;
    }

    return SmartScaffold(
      title: 'Đăng bài',
      appBarType: AppBarType.standard,
      showBackButton: true,
      body: Form(
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
                // selectedCategory: selectedCategory.value,
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
      ),
    );
  }

  Widget _buildLoginPrompt({
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required BuildContext context,
  }) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  Icons.edit_note_outlined,
                  size: isTablet ? 80 : 64,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
                SizedBox(height: isTablet ? 24 : 20),

                // Title
                Text(
                  'Đăng nhập để tạo bài đăng',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 24 : 20,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Description
                Text(
                  'Bạn cần đăng nhập để có thể tạo và đăng bài. Đăng nhập ngay để trải nghiệm đầy đủ tính năng.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 16 : 14,
                    color: theme.hintColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isTablet ? 40 : 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed('login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.login),
                    label: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Register link
                TextButton(
                  onPressed: () {
                    context.pushNamed('register');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                  child: Text(
                    'Chưa có tài khoản? Đăng ký ngay',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 32 : 24),

                // Optional: Guest browsing info
                Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: isTablet ? 20 : 16,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Expanded(
                        child: Text(
                          'Bạn có thể xem các bài đăng khác mà không cần đăng nhập',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
