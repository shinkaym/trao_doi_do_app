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
        // Form fields section with improved spacing
        _buildFormFieldsSection(),

        // Give away items section
        if (_needsGiveAwaySection) ...[
          _buildSectionDivider(),
          _buildGiveAwaySection(),
        ],

        _buildSectionDivider(),

        // Submit button
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildFormFieldsSection() {
    final fields = <Widget>[];

    // Location field
    if (_needsLocationField) {
      fields.add(_buildLocationField());
    }

    // Category field
    if (_needsCategoryField) {
      fields.add(_buildCategoryField());
    }

    // Time field
    if (_needsTimeField) {
      fields.add(_buildTimeField());
    }

    // Reward field
    if (_needsRewardField) {
      fields.add(_buildRewardField());
    }

    return Column(
      children:
          fields
              .map(
                (field) => Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 20 : 16),
                  child: field,
                ),
              )
              .toList(),
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 20),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              colorScheme.outline.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
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

  Widget _buildLocationField() {
    String hintText;
    IconData iconData;
    Color iconColor;

    switch (selectedType) {
      case CreatePostType.findLost:
        hintText = 'Ví dụ: Công viên Tao Đàn, Quận 1...';
        iconData = Icons.location_off;
        iconColor = Colors.red.shade400;
        break;
      case CreatePostType.foundItem:
        hintText = 'Ví dụ: Trước cửa hàng Circle K, Đường Nguyễn Huệ...';
        iconData = Icons.location_on;
        iconColor = Colors.green.shade400;
        break;
      default:
        hintText = 'Nhập địa điểm cụ thể...';
        iconData = Icons.location_on;
        iconColor = colorScheme.primary;
    }

    return Container(
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
        controller: locationController,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: 'Địa điểm',
          labelStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText,
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
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: iconColor, size: isTablet ? 22 : 20),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 20 : 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Vui lòng nhập địa điểm cụ thể';
          }
          if (value.trim().length < 5) {
            return 'Địa điểm quá ngắn, vui lòng nhập chi tiết hơn';
          }
          return null;
        },
      ),
    );
  }

Widget _buildCategoryField() {
  return Container(
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
      controller: categoryController,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Danh mục',
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintText: 'Ví dụ: Điện thoại, Ví, Chìa khóa, Trang sức...',
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
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập danh mục';
        }
        if (value.trim().length < 2) {
          return 'Danh mục quá ngắn, vui lòng nhập ít nhất 2 ký tự';
        }
        if (value.trim().length > 50) {
          return 'Danh mục quá dài, tối đa 50 ký tự';
        }
        // Kiểm tra chỉ chứa chữ cái, số và dấu cách
        final validPattern = RegExp(r'^[a-zA-ZÀ-ỹ0-9\s]+$');
        if (!validPattern.hasMatch(value.trim())) {
          return 'Danh mục chỉ được chứa chữ cái, số và dấu cách';
        }
        return null;
      },
    ),
  );
}
  Widget _buildTimeField() {
    String hintText;
    IconData iconData;
    Color iconColor;

    switch (selectedType) {
      case CreatePostType.findLost:
        hintText = 'Thời gian thất lạc';
        iconData = Icons.schedule;
        iconColor = Colors.orange.shade600;
        break;
      case CreatePostType.foundItem:
        hintText = 'Thời gian tìm thấy';
        iconData = Icons.event_available;
        iconColor = Colors.green.shade600;
        break;
      default:
        hintText = 'Chọn thời gian';
        iconData = Icons.access_time;
        iconColor = colorScheme.primary;
    }

    return Container(
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
        controller: timeController,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: 'Thời gian',
          labelStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText,
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
          filled: true,
          fillColor: colorScheme.surface,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: iconColor, size: isTablet ? 22 : 20),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: colorScheme.primary,
                  size: isTablet ? 20 : 18,
                ),
              ),
              onPressed: onSelectDateTime,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 20 : 16,
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
      ),
    );
  }

  Widget _buildRewardField() {
    return Container(
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
        controller: rewardController,
        style: theme.textTheme.bodyLarge,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: 'Phần thưởng (tùy chọn)',
          labelStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          hintText:
              'Ví dụ: Cảm ơn bằng tiền mặt 200.000đ, tặng voucher ăn uống...',
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
          filled: true,
          fillColor: colorScheme.surface,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              color: Colors.amber.shade700,
              size: isTablet ? 22 : 20,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 20 : 16,
          ),
        ),
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildGiveAwaySection() {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and add button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  selectedType == CreatePostType.foundItem
                      ? Icons.search_rounded
                      : Icons.card_giftcard_rounded,
                  color: colorScheme.primary,
                  size: isTablet ? 24 : 22,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedType == CreatePostType.foundItem
                          ? 'Món đồ tìm thấy'
                          : 'Danh sách món đồ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Tối đa 4 món đồ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAddItemButton(),
            ],
          ),

          SizedBox(height: isTablet ? 20 : 16),

          // Items list or empty state
          if (giveAwayItems.isEmpty)
            _buildEmptyItemsState()
          else
            _buildItemsList(),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    final isDisabled = giveAwayItems.length >= 4;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient:
            isDisabled
                ? null
                : LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
        color: isDisabled ? colorScheme.surfaceVariant : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onAddGiveAwayItem,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 12 : 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: isTablet ? 20 : 18,
                  color:
                      isDisabled ? colorScheme.onSurfaceVariant : Colors.white,
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Thêm',
                  style: TextStyle(
                    color:
                        isDisabled
                            ? colorScheme.onSurfaceVariant
                            : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 40 : 32,
        horizontal: isTablet ? 24 : 20,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: isTablet ? 48 : 40,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            selectedType == CreatePostType.foundItem
                ? 'Chưa có món đồ nào được thêm'
                : 'Danh sách còn trống',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Nhấn nút "Thêm" để bắt đầu thêm món đồ',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      children:
          giveAwayItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    index < giveAwayItems.length - 1 ? (isTablet ? 16 : 12) : 0,
              ),
              child: _buildItemCard(item, index),
            );
          }).toList(),
    );
  }

  Widget _buildItemCard(GiveAwayItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 14),
        child: Row(
          children: [
            // Index badge
            Container(
              width: isTablet ? 32 : 28,
              height: isTablet ? 32 : 28,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ),
            ),

            SizedBox(width: isTablet ? 12 : 10),

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
      width: isTablet ? 64 : 56,
      height: isTablet ? 64 : 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceVariant,
            colorScheme.surfaceVariant.withOpacity(0.7),
          ],
        ),
      ),
      child: Icon(
        Icons.image_outlined,
        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        size: isTablet ? 28 : 24,
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
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.description?.isNotEmpty == true) ...[
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            item.description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: isTablet ? 8 : 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: isTablet ? 16 : 14,
                color: colorScheme.primary,
              ),
              SizedBox(width: 4),
              Text(
                'SL: ${item.quantity}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 12 : 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemoveButton(GiveAwayItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onRemoveGiveAwayItem(item.id),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade600,
              size: isTablet ? 22 : 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: isTablet ? 64 : 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient:
            isSubmitting
                ? null
                : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
        color: isSubmitting ? colorScheme.surfaceVariant : null,
        boxShadow:
            isSubmitting
                ? null
                : [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSubmitting ? null : onSubmit,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 20,
              vertical: isTablet ? 20 : 16,
            ),
            child:
                isSubmitting
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: isTablet ? 24 : 20,
                          width: isTablet ? 24 : 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Text(
                          'Đang xử lý...',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: isTablet ? 24 : 22,
                        ),
                        SizedBox(width: isTablet ? 12 : 10),
                        Text(
                          'Tạo bài viết',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: isTablet ? 18 : 16,
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
