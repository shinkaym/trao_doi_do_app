import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/data/models/category_model.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';
import 'package:trao_doi_do_app/domain/entities/item.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/post_provider.dart';
import 'package:trao_doi_do_app/presentation/models/give_away_item.dart';
import 'package:trao_doi_do_app/presentation/providers/category_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/item_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/image_picker_bottom_sheet.dart';

class AddItemDialog extends HookConsumerWidget {
  final Function(GiveAwayItem) onItemAdded;
  final WidgetRef ref;

  const AddItemDialog({
    super.key,
    required this.onItemAdded,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 600;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final quantityController = useTextEditingController(text: '1');
    final selectedCategoryID = useState<int?>(null);
    final isManualInput = useState(true);
    final selectedPresetItem = useState<Item?>(null);
    final selectedImageData = useState<Uint8List?>(null);
    final searchQuery = useState('');
    final showSuggestions = useState(false);
    final picker = useMemoized(() => ImagePicker());
    
    // Thêm state để quản lý thông báo lỗi
    final errorMessage = useState<String?>(null);

    final categoryState = ref.watch(categoryProvider);
    final categories = categoryState.categories;
    final itemState = ref.watch(itemsListProvider);
    final filteredItems =
        itemState.items.where((item) {
          return item.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );
        }).toList();

    Future<void> _showImagePickerBottomSheet({
      required BuildContext context,
      required ImagePicker picker,
      required Function(Uint8List bytes, double sizeInMB) onImagePicked,
      String title = 'Chọn ảnh',
    }) async {
      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 600 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildDialogHeader(context, colorScheme, theme, isTablet),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị thông báo lỗi nếu có
                      if (errorMessage.value != null) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isTablet ? 16 : 12),
                          margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: colorScheme.error,
                                size: isTablet ? 20 : 18,
                              ),
                              SizedBox(width: isTablet ? 12 : 8),
                              Expanded(
                                child: Text(
                                  errorMessage.value!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => errorMessage.value = null,
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: colorScheme.error,
                                  size: isTablet ? 18 : 16,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Tên món đồ
                      _buildNameField(
                        context,
                        theme,
                        colorScheme,
                        isTablet,
                        nameController,
                        searchQuery,
                        showSuggestions,
                        selectedPresetItem,
                        selectedImageData,
                        categories,
                        selectedCategoryID,
                        isManualInput,
                        ref,
                      ),

                      // Gợi ý tìm kiếm
                      if (showSuggestions.value) ...[
                        SizedBox(height: isTablet ? 16 : 12),
                        _buildSuggestionsList(
                          context,
                          theme,
                          colorScheme,
                          isTablet,
                          itemState,
                          filteredItems,
                          categories,
                          nameController,
                          selectedPresetItem,
                          selectedCategoryID,
                          selectedImageData,
                          showSuggestions,
                          isManualInput,
                        ),
                      ],

                      SizedBox(height: isTablet ? 24 : 20),

                      // Danh mục
                      _buildCategoryField(
                        context,
                        theme,
                        colorScheme,
                        isTablet,
                        categoryState,
                        categories,
                        selectedCategoryID,
                        isManualInput,
                      ),

                      SizedBox(height: isTablet ? 24 : 20),

                      // Hình ảnh
                      _buildImageField(
                        context,
                        theme,
                        colorScheme,
                        isTablet,
                        selectedImageData,
                        picker,
                        _showImagePickerBottomSheet,
                        errorMessage, // Truyền errorMessage vào đây
                      ),

                      SizedBox(height: isTablet ? 24 : 20),

                      // Số lượng
                      _buildQuantityField(
                        context,
                        theme,
                        colorScheme,
                        isTablet,
                        quantityController,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            _buildActionButtons(
              context,
              theme,
              colorScheme,
              isTablet,
              formKey,
              nameController,
              quantityController,
              selectedImageData,
              selectedPresetItem,
              selectedCategoryID,
              ref,
              onItemAdded,
              errorMessage, // Truyền errorMessage vào đây
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_box_rounded,
              color: colorScheme.primary,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thêm món đồ',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Thông tin chi tiết về món đồ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surface.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
    TextEditingController nameController,
    ValueNotifier<String> searchQuery,
    ValueNotifier<bool> showSuggestions,
    ValueNotifier<Item?> selectedPresetItem,
    ValueNotifier<Uint8List?> selectedImageData,
    List<Category> categories,
    ValueNotifier<int?> selectedCategoryID,
    ValueNotifier<bool> isManualInput,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tên món đồ *',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: nameController,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Nhập hoặc tìm kiếm món đồ...',
              hintStyle: TextStyle(
                color: theme.hintColor.withOpacity(0.7),
                fontSize: isTablet ? 16 : 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.error, width: 1),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: isTablet ? 22 : 20,
                ),
              ),
              suffixIcon:
                  nameController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          nameController.clear();
                          searchQuery.value = '';
                          selectedPresetItem.value = null;
                          selectedImageData.value = null;
                          showSuggestions.value = false;
                        },
                      )
                      : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 20 : 16,
              ),
            ),
            onChanged: (value) {
              searchQuery.value = value;
              showSuggestions.value = value.isNotEmpty;
              selectedPresetItem.value = null;
              isManualInput.value = true;
              selectedCategoryID.value =
                  categories.isNotEmpty ? categories.first.id : null;

              if (value.isNotEmpty) {
                ref.read(itemsListProvider.notifier).search('name', value);
              } else {
                ref.read(itemsListProvider.notifier).clearFilters();
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên món đồ';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsList(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
    dynamic itemState,
    List<dynamic> filteredItems,
    List<Category> categories,
    TextEditingController nameController,
    ValueNotifier<Item?> selectedPresetItem,
    ValueNotifier<int?> selectedCategoryID,
    ValueNotifier<Uint8List?> selectedImageData,
    ValueNotifier<bool> showSuggestions,
    ValueNotifier<bool> isManualInput,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          itemState.isLoading
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        'Đang tìm kiếm...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : filteredItems.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.all(isTablet ? 12 : 8),
                itemCount: filteredItems.length,
                separatorBuilder:
                    (context, index) => Divider(
                      height: 1,
                      color: colorScheme.outline.withOpacity(0.1),
                    ),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final category = categories.firstWhere(
                    (c) => c.id == item.categoryID,
                    orElse: () => const CategoryModel(id: 0, name: 'Khác'),
                  );

                  final decodedImage = Base64Utils.decodeImageFromBase64(
                    item.image,
                  );

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 8 : 4,
                    ),
                    leading: Container(
                      width: isTablet ? 48 : 44,
                      height: isTablet ? 48 : 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colorScheme.surfaceVariant,
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            decodedImage != null
                                ? Image.memory(
                                  decodedImage,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.image_outlined,
                                        color: colorScheme.onSurfaceVariant,
                                        size: isTablet ? 24 : 20,
                                      ),
                                )
                                : Icon(
                                  Icons.image_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                  size: isTablet ? 24 : 20,
                                ),
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      category.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: isTablet ? 18 : 16,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    onTap: () {
                      nameController.text = item.name;
                      selectedPresetItem.value = item;
                      selectedCategoryID.value = item.categoryID;
                      selectedImageData.value =
                          Base64Utils.decodeImageFromBase64(item.image);
                      showSuggestions.value = false;
                      isManualInput.value = false;
                    },
                  );
                },
              ),
    );
  }

  Widget _buildCategoryField(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
    dynamic categoryState,
    List<Category> categories,
    ValueNotifier<int?> selectedCategoryID,
    ValueNotifier<bool> isManualInput,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục *',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              categoryState.isLoading
                  ? Container(
                    height: isTablet ? 64 : 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : categoryState.failure != null
                  ? Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.error),
                      color: colorScheme.errorContainer.withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colorScheme.error,
                          size: isTablet ? 24 : 20,
                        ),
                        SizedBox(width: isTablet ? 12 : 8),
                        Expanded(
                          child: Text(
                            'Lỗi tải danh mục: ${categoryState.failure!.message}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : isManualInput.value
                  ? DropdownButtonFormField<int>(
                    value: selectedCategoryID.value,
                    items:
                        categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }).toList(),
                    onChanged: (val) {
                      selectedCategoryID.value = val;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      hintText: 'Chọn danh mục',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category_rounded,
                          color: Colors.blue.shade600,
                          size: isTablet ? 22 : 20,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isTablet ? 20 : 16,
                      ),
                    ),
                    validator: (val) {
                      if (val == null) return 'Vui lòng chọn danh mục';
                      return null;
                    },
                  )
                  : Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 20 : 16,
                      horizontal: isTablet ? 20 : 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.category_rounded,
                            color: Colors.blue.shade600,
                            size: isTablet ? 22 : 20,
                          ),
                        ),
                        Text(
                          categories
                              .firstWhere(
                                (c) => c.id == selectedCategoryID.value,
                                orElse:
                                    () => const CategoryModel(
                                      id: 0,
                                      name: 'Khác',
                                    ),
                              )
                              .name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildImageField(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
    ValueNotifier<Uint8List?> selectedImageData,
    ImagePicker picker,
    Function showImagePickerBottomSheet,
    ValueNotifier<String?> errorMessage, // Thêm parameter này
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hình ảnh *',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Center(
          child: GestureDetector(
            onTap: () {
              showImagePickerBottomSheet(
                context: context,
                picker: picker,
                title: 'Chọn ảnh món đồ',
                onImagePicked: (bytes, sizeInMB) {
                  if (sizeInMB > 5) {
                    // Thay thế showErrorSnackBar bằng việc set errorMessage
                    errorMessage.value = 'Ảnh vượt quá 5MB. Vui lòng chọn ảnh khác.';
                    return;
                  }
                  selectedImageData.value = bytes;
                  // Xóa error message khi chọn ảnh thành công
                  if (errorMessage.value != null && errorMessage.value!.contains('ảnh')) {
                    errorMessage.value = null;
                  }
                },
              );
            },
            child: Container(
              width: isTablet ? 160 : 140,
              height: isTablet ? 160 : 140,
              child:
                  selectedImageData.value != null
                      ? _buildSelectedImageCard(
                        context,
                        theme,
                        colorScheme,
                        isTablet,
                        selectedImageData,
                      )
                      : _buildPlaceholderCard(colorScheme, theme, isTablet),
            ),
          ),
        ),

        // Thông tin hướng dẫn
        SizedBox(height: isTablet ? 12 : 8),
        Center(
          child: Text(
            selectedImageData.value != null
                ? 'Nhấn để thay đổi ảnh'
                : 'Nhấn để chọn ảnh (Tối đa 5MB)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: isTablet ? 13 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCard(
    ColorScheme colorScheme,
    ThemeData theme,
    bool isTablet,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo,
                size: isTablet ? 32 : 24,
                color: colorScheme.primary,
              ),
              SizedBox(height: isTablet ? 8 : 4),
              Text(
                'Thêm ảnh',
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImageCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
    ValueNotifier<Uint8List?> selectedImageData,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                selectedImageData.value != null
                    ? Image.memory(
                      selectedImageData.value!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorImageWidget(
                          colorScheme,
                          theme,
                          isTablet,
                        );
                      },
                    )
                    : Container(),
          ),

          // Overlay với icon khi có ảnh
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.3),
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: colorScheme.primary,
                    size: isTablet ? 24 : 20,
                  ),
                ),
              ),
            ),
          ),

          // Nút xóa ảnh
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                selectedImageData.value = null;
              },
              child: Container(
                width: isTablet ? 32 : 28,
                height: isTablet ? 32 : 28,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: isTablet ? 18 : 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImageWidget(
    ColorScheme colorScheme,
    ThemeData theme,
    bool isTablet,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: colorScheme.error,
            size: isTablet ? 40 : 32,
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Lỗi hiển thị ảnh',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
              fontSize: isTablet ? 12 : 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Nhấn để chọn lại',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error.withOpacity(0.7),
              fontSize: isTablet ? 11 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityField(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
    TextEditingController quantityController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số lượng *',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: quantityController,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Nhập số lượng',
              hintStyle: TextStyle(
                color: theme.hintColor.withOpacity(0.7),
                fontSize: isTablet ? 16 : 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.error, width: 1),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.numbers_rounded,
                  color: Colors.green.shade600,
                  size: isTablet ? 22 : 20,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 20 : 16,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập số lượng';
              }
              final quantity = int.tryParse(value);
              if (quantity == null || quantity <= 0) {
                return 'Số lượng phải lớn hơn 0';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

// Chỉnh sửa trong method _buildActionButtons - thêm parameter errorMessage
Widget _buildActionButtons(
  BuildContext context,
  ThemeData theme,
  ColorScheme colorScheme,
  bool isTablet,
  GlobalKey<FormState> formKey,
  TextEditingController nameController,
  TextEditingController quantityController,
  ValueNotifier<Uint8List?> selectedImageData,
  ValueNotifier<Item?> selectedPresetItem,
  ValueNotifier<int?> selectedCategoryID,
  WidgetRef ref,
  Function(GiveAwayItem) onItemAdded,
  ValueNotifier<String?> errorMessage, // Thêm parameter này
) {
  return Container(
    padding: EdgeInsets.fromLTRB(
      isTablet ? 24 : 20,
      isTablet ? 16 : 12,
      isTablet ? 24 : 20,
      isTablet ? 24 : 20,
    ),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      border: Border(
        top: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 14,
                horizontal: isTablet ? 24 : 20,
              ),
              side: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close_rounded, size: isTablet ? 20 : 18),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Hủy',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                if (selectedImageData.value == null) {
                  // Thay thế context.showErrorSnackBar bằng errorMessage
                  errorMessage.value = 'Vui lòng chọn hình ảnh cho món đồ';
                  return;
                }

                final item = GiveAwayItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  description: selectedPresetItem.value?.description ?? '',
                  imageData: selectedImageData.value,
                  quantity: int.tryParse(quantityController.text) ?? 1,
                  isFromPreset: selectedPresetItem.value != null,
                  categoryId: selectedCategoryID.value,
                );

                final dataUri = Base64Utils.encodeImageToDataUri(
                  item.imageData!,
                );
                final base64Image = base64Encode(item.imageData!);
                final postNotifier = ref.read(postProvider.notifier);

                if (item.isFromPreset) {
                  postNotifier.addOldItem(
                    OldItem(
                      itemID: selectedPresetItem.value!.id,
                      quantity: item.quantity,
                      image: dataUri,
                    ),
                  );
                } else {
                  postNotifier.addNewItem(
                    NewItem(
                      name: item.name,
                      quantity: item.quantity,
                      categoryID: item.categoryId!,
                      image: dataUri,
                    ),
                  );
                }

                postNotifier.addImage(base64Image);
                onItemAdded(item);
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 14,
                horizontal: isTablet ? 24 : 20,
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: colorScheme.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: isTablet ? 20 : 18),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Thêm món đồ',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}