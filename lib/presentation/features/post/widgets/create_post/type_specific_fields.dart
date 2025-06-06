import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/models/give_away_item.dart';

class TypeSpecificFields extends HookConsumerWidget {
  final CreatePostType selectedType;
  final TextEditingController locationController;
  final TextEditingController timeController;
  final TextEditingController rewardController;
  final TextEditingController categoryController;
  final Category? selectedCategory;
  final VoidCallback onSelectDateTime;
  final List<GiveAwayItem> giveAwayItems;
  final VoidCallback onAddGiveAwayItem;
  final Function(String) onRemoveGiveAwayItem;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const TypeSpecificFields({
    super.key,
    required this.selectedType,
    required this.locationController,
    required this.timeController,
    required this.rewardController,
    required this.categoryController,
    this.selectedCategory,
    required this.onSelectDateTime,
    required this.giveAwayItems,
    required this.onAddGiveAwayItem,
    required this.onRemoveGiveAwayItem,
    required this.isSubmitting,
    required this.onSubmit,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Common fields for types that need them
        if (_needsLocationField) ...[_buildLocationField(), _buildSpacing()],

        // Category field (only for findLost)
        if (_needsCategoryField) ...[_buildCategoryField(), _buildSpacing()],

        // Time field for types that need it
        if (_needsTimeField) ...[_buildTimeField(), _buildSpacing()],

        // Reward field (only for findLost)
        if (_needsRewardField) ...[_buildRewardField(), _buildSpacing()],

        // Give away items section
        if (_needsGiveAwaySection) ...[
          _buildGiveAwaySection(),
          _buildSpacing(),
        ],

        // Submit button
        _buildSubmitButton(),
      ],
    );
  }

  // Helper getters to determine which fields are needed
  bool get _needsLocationField =>
      selectedType != CreatePostType.freePost &&
      selectedType != CreatePostType.giveAway;
  bool get _needsCategoryField => selectedType == CreatePostType.findLost;
  bool get _needsTimeField =>
      selectedType != CreatePostType.freePost &&
      selectedType != CreatePostType.giveAway;
  bool get _needsRewardField => selectedType == CreatePostType.findLost;
  bool get _needsGiveAwaySection =>
      selectedType == CreatePostType.giveAway ||
      selectedType == CreatePostType.foundItem;

  Widget _buildSpacing() => SizedBox(height: isTablet ? 20 : 16);

  Widget _buildLocationField() {
    String hintText;
    switch (selectedType) {
      case CreatePostType.findLost:
        hintText = 'Nơi thất lạc...';
        break;
      case CreatePostType.foundItem:
        hintText = 'Nơi tìm thấy món đồ...';
        break;
      default:
        hintText = 'Nhập địa điểm...';
    }

    return TextFormField(
      controller: locationController,
      decoration: InputDecoration(
        labelText: 'Địa điểm *',
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.location_on),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập địa điểm';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryField() {
    return TextFormField(
      controller: categoryController,
      decoration: InputDecoration(
        labelText: 'Danh mục',
        hintText: 'Nhập danh mục các món đồ...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.category),
      ),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildTimeField() {
    String hintText;
    switch (selectedType) {
      case CreatePostType.findLost:
        hintText = 'Chọn thời gian thất lạc';
        break;
      case CreatePostType.foundItem:
        hintText = 'Chọn thời gian tìm thấy';
        break;
      default:
        hintText = 'Chọn thời gian';
    }

    return TextFormField(
      controller: timeController,
      decoration: InputDecoration(
        labelText: 'Thời gian *',
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.access_time),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: onSelectDateTime,
        ),
      ),
      readOnly: true,
      onTap: onSelectDateTime,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng chọn thời gian';
        }
        return null;
      },
    );
  }

  Widget _buildRewardField() {
    return TextFormField(
      controller: rewardController,
      decoration: InputDecoration(
        labelText: 'Phần thưởng (tùy chọn)',
        hintText: 'Ví dụ: tặng quà, cảm ơn bằng hiện vật...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.card_giftcard),
      ),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildGiveAwaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedType == CreatePostType.foundItem
                  ? 'Món đồ tìm thấy'
                  : 'Danh sách món đồ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAddGiveAwayItem,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                selectedType == CreatePostType.foundItem
                    ? 'Thêm món đồ'
                    : 'Thêm món đồ',
              ),
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

        // Items list
        if (giveAwayItems.isEmpty)
          _buildEmptyItemsState()
        else
          _buildItemsList(),
      ],
    );
  }

  Widget _buildEmptyItemsState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
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
            selectedType == CreatePostType.foundItem
                ? 'Chưa có món đồ nào được thêm'
                : 'Chưa có món đồ nào',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 4),
          Text(
            'Nhấn "Thêm món đồ" để bắt đầu',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: giveAwayItems.length,
      separatorBuilder: (context, index) => SizedBox(height: isTablet ? 12 : 8),
      itemBuilder: (context, index) {
        final item = giveAwayItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(GiveAwayItem item) {
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
            _buildItemImage(item),
            SizedBox(width: isTablet ? 16 : 12),

            // Item Info
            Expanded(child: _buildItemInfo(item)),

            // Remove Button
            _buildRemoveButton(item),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(GiveAwayItem item) {
    return Container(
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
                ? Image.memory(item.imageData!, fit: BoxFit.cover)
                : item.imagePath != null
                ? Image.network(
                  item.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildPlaceholderImage(),
                )
                : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.image,
        color: colorScheme.onSurfaceVariant,
        size: isTablet ? 24 : 20,
      ),
    );
  }

  Widget _buildItemInfo(GiveAwayItem item) {
    return Column(
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
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
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
    );
  }

  Widget _buildRemoveButton(GiveAwayItem item) {
    return IconButton(
      onPressed: () => onRemoveGiveAwayItem(item.id),
      icon: Icon(
        Icons.delete_outline,
        color: Colors.red,
        size: isTablet ? 24 : 20,
      ),
      constraints: BoxConstraints(
        minWidth: isTablet ? 40 : 32,
        minHeight: isTablet ? 40 : 32,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 56 : 48,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            isSubmitting
                ? SizedBox(
                  width: isTablet ? 24 : 20,
                  height: isTablet ? 24 : 20,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Đăng bài',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
