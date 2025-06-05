import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/data/models/category_model.dart';
import 'package:trao_doi_do_app/domain/entities/item.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/post_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/create_post_screen.dart';
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

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_box_outlined, color: context.appColors.primary),
          const SizedBox(width: 8),
          const Text('Thêm món đồ'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên món đồ với tìm kiếm gợi ý
                Text(
                  'Tên món đồ *',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Nhập hoặc tìm kiếm món đồ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        nameController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                nameController.clear();
                                searchQuery.value = '';
                                selectedPresetItem.value = null;
                                selectedImageData.value = null;
                                showSuggestions.value = false;
                              },
                            )
                            : null,
                  ),
                  onChanged: (value) {
                    searchQuery.value = value;
                    showSuggestions.value = value.isNotEmpty;
                    selectedPresetItem.value = null;
                    isManualInput.value = true;
                    selectedCategoryID.value =
                        categories.isNotEmpty ? categories.first.id : null;

                    if (value.isNotEmpty) {
                      ref
                          .read(itemsListProvider.notifier)
                          .search('name', value);
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

                // Gợi ý tìm kiếm từ database
                if (showSuggestions.value) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: context.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child:
                          itemState.isLoading
                              ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : filteredItems.isEmpty
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Không tìm thấy món đồ nào',
                                  textAlign: TextAlign.center,
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  final category = categories.firstWhere(
                                    (c) => c.id == item.categoryID,
                                    orElse:
                                        () => const CategoryModel(
                                          id: 0,
                                          name: 'Khác',
                                        ),
                                  );

                                  return ListTile(
                                    dense: true,
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        color:
                                            context.colorScheme.surfaceVariant,
                                        child:
                                            item.decodedImage != null
                                                ? Image.memory(
                                                  item.decodedImage!,
                                                  fit: BoxFit.cover,
                                                )
                                                : Icon(
                                                  Icons.image,
                                                  color:
                                                      context
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                  size: 20,
                                                ),
                                      ),
                                    ),
                                    title: Text(
                                      item.name,
                                      style: context.textTheme.bodyMedium,
                                    ),
                                    subtitle: Text(
                                      category.name,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: context.theme.hintColor,
                                          ),
                                    ),
                                    onTap: () {
                                      nameController.text = item.name;
                                      selectedPresetItem.value = item;
                                      selectedCategoryID.value =
                                          item.categoryID;
                                      selectedImageData.value =
                                          item.decodedImage;
                                      showSuggestions.value = false;
                                      isManualInput.value = false;
                                    },
                                  );
                                },
                              ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Text(
                  'Danh mục *',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                if (categoryState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (categoryState.failure != null)
                  Text(
                    'Lỗi tải danh mục: ${categoryState.failure!.message}',
                    style: const TextStyle(color: Colors.red),
                  )
                else if (isManualInput.value)
                  DropdownButtonFormField<int>(
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Chọn danh mục',
                    ),
                    validator: (val) {
                      if (val == null) return 'Vui lòng chọn danh mục';
                      return null;
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colorScheme.outline.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      categories
                          .firstWhere(
                            (c) => c.id == selectedCategoryID.value,
                            orElse:
                                () => const CategoryModel(id: 0, name: 'Khác'),
                          )
                          .name,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),

                const SizedBox(height: 16),

                // Hình ảnh món đồ
                Text(
                  'Hình ảnh *',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            selectedImageData.value != null
                                ? Image.memory(
                                  selectedImageData.value!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                                : InkWell(
                                  onTap: () {
                                    _showImagePickerBottomSheet(
                                      context: context,
                                      picker: picker,
                                      title: 'Chọn ảnh món đồ',
                                      onImagePicked: (bytes, sizeInMB) {
                                        if (sizeInMB > 5) {
                                          context.showErrorSnackBar(
                                            'Ảnh vượt quá 5MB',
                                          );
                                          return;
                                        }
                                        selectedImageData.value = bytes;
                                      },
                                    );
                                  },

                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: context.colorScheme.outline
                                            .withOpacity(0.4),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 20,
                                          color: context.theme.hintColor,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Chọn ảnh',
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                                fontSize: 12,
                                                color: context.theme.hintColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                      ),
                      if (selectedImageData.value != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              selectedImageData.value = null;
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Số lượng
                Text(
                  'Số lượng *',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    hintText: 'Nhập số lượng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.numbers),
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(color: context.appColors.secondaryTextColor),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              if (selectedImageData.value == null) {
                context.showErrorSnackBar('Vui lòng chọn hình ảnh cho món đồ');
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

              final base64Image = base64Encode(item.imageData!);
              final postNotifier = ref.read(postProvider.notifier);

              if (item.isFromPreset) {
                postNotifier.addOldItem(
                  OldItem(
                    itemID: selectedPresetItem.value!.id,
                    quantity: item.quantity,
                    image: base64Image,
                  ),
                );
              } else {
                postNotifier.addNewItem(
                  NewItem(
                    name: item.name,
                    quantity: item.quantity,
                    categoryID: item.categoryId!,
                    image: base64Image,
                  ),
                );
              }

              postNotifier.addImage(base64Image);
              onItemAdded(item);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.appColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
