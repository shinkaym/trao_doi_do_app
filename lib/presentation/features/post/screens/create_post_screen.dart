import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/extensions/image_extension.dart';
import 'package:trao_doi_do_app/data/models/category_model.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/usecases/create_post_usecase.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/post_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';
import 'package:trao_doi_do_app/presentation/providers/category_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/item_provider.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';
import 'package:trao_doi_do_app/domain/entities/item.dart';

// Enum cho loại bài đăng
enum CreatePostType {
  giveAway(1, 'Gửi đồ cũ', Icons.volunteer_activism, Colors.blue),
  foundItem(2, 'Nhặt đồ thất lạc', Icons.help_outline, Colors.green),
  findLost(3, 'Tìm đồ thất lạc', Icons.search, Colors.red),
  freePost(4, 'Bài đăng tự do', Icons.edit_note, Colors.purple);

  final int typeValue;
  final String label;
  final IconData icon;
  final Color color;

  const CreatePostType(this.typeValue, this.label, this.icon, this.color);
}

// Model cho món đồ trong bài đăng gửi đồ cũ
class GiveAwayItem {
  String id;
  String name;
  String? description;
  Uint8List? imageData;
  String? imagePath;
  int quantity;
  bool isFromPreset;
  int? categoryId;

  GiveAwayItem({
    required this.id,
    required this.name,
    this.description,
    this.imageData,
    this.imagePath,
    this.quantity = 1,
    this.isFromPreset = false,
    this.categoryId,
  });
}

// Model cho hình ảnh
class PostImage {
  String id;
  Uint8List? imageData;
  String? imagePath;
  double sizeInMB;

  PostImage({
    required this.id,
    this.imageData,
    this.imagePath,
    required this.sizeInMB,
  });
}

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _rewardController = TextEditingController();
  final _timeController = TextEditingController();

  CreatePostType _selectedType = CreatePostType.findLost;
  List<PostImage> _images = [];
  List<GiveAwayItem> _giveAwayItems = [];
  DateTime? _selectedDateTime;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  // Selected category for lost/found items
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load categories and items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).getCategories();
      ref.read(itemProvider.notifier).getItems(refresh: true);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _rewardController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _handleTypeChange(CreatePostType type) {
    setState(() {
      _selectedType = type;
      // Reset specific fields when changing type
      _images.clear();
      _giveAwayItems.clear();
      _selectedDateTime = null;
      _selectedCategory = null;
      _locationController.clear();
      _categoryController.clear();
      _rewardController.clear();
      _timeController.clear();
    });
  }

  Future<void> _pickImages() async {
    if (_images.length >= 4) {
      context.showErrorSnackBar('Chỉ được chọn tối đa 4 ảnh');
      return;
    }

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedImage = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      imageQuality: 85,
                    );
                    if (pickedImage != null) {
                      final bytes = await pickedImage.readAsBytes();
                      final sizeInMB = bytes.lengthInBytes / (1024 * 1024);

                      if (sizeInMB > 5) {
                        context.showErrorSnackBar('Ảnh vượt quá 5MB');
                        return;
                      }

                      setState(() {
                        _images.add(
                          PostImage(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            imageData: bytes,
                            sizeInMB: sizeInMB,
                          ),
                        );
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedImage = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800,
                      imageQuality: 85,
                    );
                    if (pickedImage != null) {
                      final bytes = await pickedImage.readAsBytes();
                      final sizeInMB = bytes.lengthInBytes / (1024 * 1024);

                      if (sizeInMB > 5) {
                        context.showErrorSnackBar('Ảnh vượt quá 5MB');
                        return;
                      }

                      setState(() {
                        _images.add(
                          PostImage(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            imageData: bytes,
                            sizeInMB: sizeInMB,
                          ),
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage({
    required BuildContext context,
    required void Function(Uint8List) onPicked,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      onPicked(bytes);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      onPicked(bytes);
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _removeImage(String imageId) {
    setState(() {
      _images.removeWhere((img) => img.id == imageId);
    });
  }

  Future<void> _selectDateTime() async {
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
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _timeController.text = _formatDateTime(_selectedDateTime!);
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _addGiveAwayItem() {
    _showAddItemDialog();
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();
    int? selectedCategoryID;
    bool isManualInput = true;

    Item? selectedPresetItem;
    Uint8List? selectedImageData;
    String searchQuery = '';
    bool showSuggestions = false;

    context.showAppDialog(
      child: Consumer(
        builder: (context, ref, child) {
          final categoryState = ref.watch(categoryProvider);
          final categories = categoryState.categories;
          final itemState = ref.watch(itemProvider);

          print('DEBUG: Items count: ${itemState.items.length}');
          print('DEBUG: Is loading: ${itemState.isLoading}');

          // Debug từng item
          for (var item in itemState.items) {
            print(
              'DEBUG: Item ${item.name} - has image: ${item.image != null}',
            );
          }

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              // Filter items based on search query
              final filteredItems =
                  itemState.items.where((item) {
                    return item.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    );
                  }).toList();

              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.add_box_outlined,
                      color: context.appColors.primary,
                    ),
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
                                          setDialogState(() {
                                            searchQuery = '';
                                            selectedPresetItem = null;
                                            selectedImageData = null;
                                            showSuggestions = false;
                                          });
                                        },
                                      )
                                      : null,
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                searchQuery = value;
                                showSuggestions = value.isNotEmpty;
                                selectedPresetItem = null;
                                isManualInput = true;
                                selectedCategoryID =
                                    categories.isNotEmpty
                                        ? categories.first.id
                                        : null;
                              });

                              // Search items with debounce
                              if (value.isNotEmpty) {
                                ref
                                    .read(itemProvider.notifier)
                                    .setSearchOptions(
                                      searchBy: 'name',
                                      searchValue: value,
                                    );
                              } else {
                                ref.read(itemProvider.notifier).clearFilters();
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
                          if (showSuggestions) ...[
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: context.colorScheme.outline
                                        .withOpacity(0.2),
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
                                            final category = categories
                                                .firstWhere(
                                                  (c) =>
                                                      c.id == item.categoryID,
                                                  orElse:
                                                      () => const CategoryModel(
                                                        id: 0,
                                                        name: 'Khác',
                                                      ),
                                                );

                                            return ListTile(
                                              dense: true,
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  color:
                                                      context
                                                          .colorScheme
                                                          .surfaceVariant,
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
                                                style:
                                                    context
                                                        .textTheme
                                                        .bodyMedium,
                                              ),
                                              subtitle: Text(
                                                category.name,
                                                style: context
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          context
                                                              .theme
                                                              .hintColor,
                                                    ),
                                              ),
                                              onTap: () {
                                                setDialogState(() {
                                                  nameController.text =
                                                      item.name;
                                                  selectedPresetItem = item;
                                                  selectedCategoryID =
                                                      item.categoryID;
                                                  selectedImageData =
                                                      item.decodedImage;
                                                  showSuggestions = false;
                                                  isManualInput = false;
                                                });
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
                              style: TextStyle(color: Colors.red),
                            )
                          else if (isManualInput)
                            DropdownButtonFormField<int>(
                              value: selectedCategoryID,
                              items:
                                  categories.map((cat) {
                                    return DropdownMenuItem<int>(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  selectedCategoryID = val;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: 'Chọn danh mục',
                              ),
                              validator: (val) {
                                if (val == null)
                                  return 'Vui lòng chọn danh mục';
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
                                  color: context.colorScheme.outline
                                      .withOpacity(0.4),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                categories
                                    .firstWhere(
                                      (c) => c.id == selectedCategoryID,
                                      orElse:
                                          () => const CategoryModel(
                                            id: 0,
                                            name: 'Khác',
                                          ),
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
                                      selectedImageData != null
                                          ? Image.memory(
                                            selectedImageData!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                          : InkWell(
                                            onTap: () {
                                              _pickImage(
                                                context: dialogContext,
                                                onPicked: (bytes) {
                                                  setDialogState(() {
                                                    selectedImageData = bytes;
                                                  });
                                                },
                                              );
                                            },
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: context
                                                      .colorScheme
                                                      .outline
                                                      .withOpacity(0.4),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_a_photo,
                                                    size: 20,
                                                    color:
                                                        context.theme.hintColor,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Chọn ảnh',
                                                    style: context
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              context
                                                                  .theme
                                                                  .hintColor,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                ),
                                if (selectedImageData != null)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setDialogState(
                                          () => selectedImageData = null,
                                        );
                                      },
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: context.appColors.secondaryTextColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        if (selectedImageData == null) {
                          context.showErrorSnackBar(
                            'Vui lòng chọn hình ảnh cho món đồ',
                          );
                          return;
                        }

                        final item = GiveAwayItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          description: selectedPresetItem?.description ?? '',
                          imageData: selectedImageData,
                          quantity: int.tryParse(quantityController.text) ?? 1,
                          isFromPreset: selectedPresetItem != null,
                          categoryId: selectedCategoryID,
                        );

                        final base64Image = base64Encode(item.imageData!);
                        final postNotifier = ref.read(postProvider.notifier);

                        if (item.isFromPreset) {
                          final categories =
                              ref.read(categoryProvider).categories;
                          final matchedCategory = categories.firstWhere(
                            (c) => c.id == selectedPresetItem!.categoryID,
                            orElse: () => CategoryModel(id: 0, name: 'Khác'),
                          );

                          postNotifier.addOldItem(
                            OldItem(
                              itemID: selectedPresetItem!.id,
                              quantity: item.quantity,
                              categoryName: matchedCategory.name,
                            ),
                          );
                        } else {
                          final categories =
                              ref.read(categoryProvider).categories;
                          final categoryName =
                              categories
                                  .firstWhere(
                                    (c) => c.id == item.categoryId,
                                    orElse:
                                        () =>
                                            CategoryModel(id: 0, name: 'Khác'),
                                  )
                                  .name;

                          postNotifier.addNewItem(
                            NewItem(
                              name: item.name,
                              quantity: item.quantity,
                              categoryID: item.categoryId!,
                              categoryName: categoryName,
                            ),
                          );
                        }

                        postNotifier.addImage(base64Image);

                        setState(() {
                          _giveAwayItems.add(item);
                        });

                        Navigator.pop(dialogContext);
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
            },
          );
        },
      ),
    );
  }

  void _removeGiveAwayItem(String itemId) {
    setState(() {
      _giveAwayItems.removeWhere((item) => item.id == itemId);
    });
  }

  Post _buildPost() {
    final typeValue = _selectedType.typeValue;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final imagesBase64 =
        _images.map((img) => base64Encode(img.imageData!)).toList();

    final info = <String, dynamic>{'description': description};

    if (_selectedType == CreatePostType.findLost) {
      info['lostLocation'] = _locationController.text.trim();
      info['lostDate'] = _selectedDateTime?.toIso8601String() ?? '';
      info['categoryID'] = _selectedCategory?.id;
      info['reward'] = _rewardController.text.trim();
    } else if (_selectedType == CreatePostType.foundItem) {
      info['foundLocation'] = _locationController.text.trim();
      info['foundDate'] = _selectedDateTime?.toIso8601String() ?? '';
      info['categoryID'] = _selectedCategory?.id;
    }

    final postNotifier = ref.read(postProvider.notifier);

    return Post(
      authorID: 1, // mặc định
      title: title,
      type: typeValue,
      info: jsonEncode(info),
      images: imagesBase64,
      newItems: postNotifier.state.newItems,
      oldItems: postNotifier.state.oldItems,
    );
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final useCase = ref.read(createPostUseCaseProvider);
    final post = _buildPost();

    setState(() {
      _isSubmitting = true;
    });

    final result = await useCase(post);

    result.fold(
      (failure) {
        context.showErrorSnackBar(failure.message);
      },
      (_) {
        context.showSuccessSnackBar('Đăng bài thành công!');
        Navigator.pop(context);
      },
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String? _validatePostData() {
    switch (_selectedType) {
      case CreatePostType.findLost:
      case CreatePostType.foundItem:
        if (_locationController.text.trim().isEmpty) {
          return 'Vui lòng nhập địa điểm';
        }
        if (_selectedCategory == null) {
          return 'Vui lòng chọn danh mục';
        }
        if (_selectedDateTime == null) {
          return 'Vui lòng chọn thời gian';
        }
        break;
      case CreatePostType.giveAway:
        if (_giveAwayItems.isEmpty) {
          return 'Vui lòng thêm ít nhất một món đồ';
        }
        break;
      case CreatePostType.freePost:
        // No additional validation needed
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(title: 'Đăng bài', showBackButton: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Type Selection
              _buildPostTypeSelection(isTablet, theme, colorScheme),
              SizedBox(height: isTablet ? 32 : 24),

              // Common Fields
              _buildCommonFields(isTablet, theme, colorScheme),

              // Type-specific Fields
              _buildTypeSpecificFields(isTablet, theme, colorScheme),

              SizedBox(height: isTablet ? 32 : 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostTypeSelection(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại bài đăng',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 2,
            childAspectRatio: isTablet ? 1.1 : 1.0,
            crossAxisSpacing: isTablet ? 16 : 12,
            mainAxisSpacing: isTablet ? 16 : 12,
          ),
          itemCount: CreatePostType.values.length,
          itemBuilder: (context, index) {
            final type = CreatePostType.values[index];
            final isSelected = _selectedType == type;

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      isSelected
                          ? type.color
                          : colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => _handleTypeChange(type),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: isSelected ? type.color.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type.icon,
                        size: isTablet ? 32 : 28,
                        color: isSelected ? type.color : theme.hintColor,
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        type.label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? type.color : theme.hintColor,
                          fontSize: isTablet ? 14 : 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommonFields(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Tiêu đề bài đăng *',
            hintText: 'Nhập tiêu đề mô tả ngắn gọn...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.title),
          ),
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tiêu đề bài đăng';
            }
            if (value.trim().length < 10) {
              return 'Tiêu đề phải có ít nhất 10 ký tự';
            }
            return null;
          },
        ),
        SizedBox(height: isTablet ? 20 : 16),

        // Description
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Mô tả chi tiết *',
            hintText: 'Mô tả chi tiết về bài đăng của bạn...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          maxLength: 500,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập mô tả chi tiết';
            }
            if (value.trim().length < 20) {
              return 'Mô tả phải có ít nhất 20 ký tự';
            }
            return null;
          },
        ),
        SizedBox(height: isTablet ? 20 : 16),

        // Images (except for giveAway type)
        if (_selectedType != CreatePostType.giveAway) ...[
          _buildImageSection(isTablet, theme, colorScheme),
          SizedBox(height: isTablet ? 20 : 16),
        ],
      ],
    );
  }

  Widget _buildImageSection(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hình ảnh',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' (tối đa 4 ảnh, mỗi ảnh ≤ 5MB)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 12 : 8),

        Container(
          height: isTablet ? 120 : 100,
          child: Row(
            children: [
              // Add image button
              if (_images.length < 4)
                Container(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 120 : 100,
                  margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.primary.withOpacity(0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: InkWell(
                      onTap: _pickImages,
                      borderRadius: BorderRadius.circular(12),
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
                ),

              // Selected images
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final image = _images[index];
                    return Container(
                      width: isTablet ? 120 : 100,
                      height: isTablet ? 120 : 100,
                      margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                      child: Stack(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  image.imageData != null
                                      ? Image.memory(
                                        image.imageData!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit:
                                            BoxFit
                                                .cover, // hoặc BoxFit.contain nếu muốn vừa khít
                                      )
                                      : Icon(
                                        Icons.image,
                                        size: isTablet ? 32 : 24,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () => _removeImage(image.id),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificFields(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    switch (_selectedType) {
      case CreatePostType.findLost:
      case CreatePostType.foundItem:
        return _buildLostFoundFields(isTablet, theme, colorScheme);
      case CreatePostType.giveAway:
        return _buildGiveAwayFields(isTablet, theme, colorScheme);
      case CreatePostType.freePost:
        return _buildSubmitButton(isTablet, theme, colorScheme);
    }
  }

  Widget _buildLostFoundFields(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Địa điểm *',
            hintText: 'Nơi thất lạc/tìm thấy...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập địa điểm';
            }
            return null;
          },
        ),
        SizedBox(height: isTablet ? 20 : 16),

        // Category
        Consumer(
          builder: (context, ref, child) {
            final categoryState = ref.watch(categoryProvider);
            final categories = categoryState.categories;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (categoryState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (categoryState.failure != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Lỗi tải danh mục: ${categoryState.failure!.message}',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                else
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Danh mục *',
                      hintText: 'Chọn danh mục phù hợp...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items:
                        categories.map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                    onChanged: (Category? value) {
                      setState(() {
                        _selectedCategory = value;
                        _categoryController.text = value?.name ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Vui lòng chọn danh mục';
                      }
                      return null;
                    },
                  ),
              ],
            );
          },
        ),
        SizedBox(height: isTablet ? 20 : 16),

        // Date Time
        TextFormField(
          controller: _timeController,
          decoration: InputDecoration(
            labelText: 'Thời gian *',
            hintText: 'Chọn thời gian thất lạc/tìm thấy',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.access_time),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDateTime,
            ),
          ),
          readOnly: true,
          onTap: _selectDateTime,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng chọn thời gian';
            }
            return null;
          },
        ),
        SizedBox(height: isTablet ? 20 : 16),

        // Reward (optional for findLost)
        if (_selectedType == CreatePostType.findLost) ...[
          TextFormField(
            controller: _rewardController,
            decoration: InputDecoration(
              labelText: 'Tiền thưởng (tùy chọn)',
              hintText: 'Số tiền thưởng cho người tìm thấy...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.monetization_on),
              suffixText: 'VNĐ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: isTablet ? 20 : 16),
        ],

        _buildSubmitButton(isTablet, theme, colorScheme),
      ],
    );
  }

  Widget _buildGiveAwayFields(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Give Away Items Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách món đồ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addGiveAwayItem,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm món đồ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),

        // Give Away Items List
        if (_giveAwayItems.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: isTablet ? 48 : 40,
                  color: theme.hintColor,
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Chưa có món đồ nào',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 4),
                Text(
                  'Nhấn "Thêm món đồ" để bắt đầu',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _giveAwayItems.length,
            separatorBuilder:
                (context, index) => SizedBox(height: isTablet ? 12 : 8),
            itemBuilder: (context, index) {
              final item = _giveAwayItems[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  child: Row(
                    children: [
                      // Item Image
                      Container(
                        width: isTablet ? 60 : 50,
                        height: isTablet ? 60 : 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorScheme.surfaceVariant,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              item.imageData != null
                                  ? Image.memory(
                                    item.imageData!,
                                    fit: BoxFit.cover,
                                  )
                                  : item.imagePath != null
                                  ? Image.network(
                                    item.imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: colorScheme.surfaceVariant,
                                        child: Icon(
                                          Icons.image,
                                          color: colorScheme.onSurfaceVariant,
                                          size: isTablet ? 24 : 20,
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    color: colorScheme.surfaceVariant,
                                    child: Icon(
                                      Icons.image,
                                      color: colorScheme.onSurfaceVariant,
                                      size: isTablet ? 24 : 20,
                                    ),
                                  ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 16 : 12),

                      // Item Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.description?.isNotEmpty == true) ...[
                              SizedBox(height: isTablet ? 4 : 2),
                              Text(
                                item.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: isTablet ? 4 : 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.numbers,
                                  size: isTablet ? 16 : 14,
                                  color: theme.hintColor,
                                ),
                                SizedBox(width: isTablet ? 4 : 2),
                                Text(
                                  'Số lượng: ${item.quantity}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Remove Button
                      IconButton(
                        onPressed: () => _removeGiveAwayItem(item.id),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: isTablet ? 24 : 20,
                        ),
                        constraints: BoxConstraints(
                          minWidth: isTablet ? 40 : 32,
                          minHeight: isTablet ? 40 : 32,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        SizedBox(height: isTablet ? 24 : 20),
        _buildSubmitButton(isTablet, theme, colorScheme),
      ],
    );
  }

  Widget _buildSubmitButton(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 56 : 48,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _isSubmitting ? 0 : 2,
        ),
        child:
            _isSubmitting
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: isTablet ? 20 : 16,
                      height: isTablet ? 20 : 16,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Text(
                      'Đang đăng bài...',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Đăng bài',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
