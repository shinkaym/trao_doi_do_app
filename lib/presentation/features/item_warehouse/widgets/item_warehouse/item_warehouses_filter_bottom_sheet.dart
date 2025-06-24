import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';

class ItemWarehousesFilterBottomSheet extends StatefulWidget {
  final Category? selectedCategory; // Changed to single category
  final List<Category> availableCategories;
  final SortOrder selectedSort;
  final Function(Category?, SortOrder) onApplyFilters; // Changed signature
  final VoidCallback onResetFilters;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const ItemWarehousesFilterBottomSheet({
    super.key,
    required this.selectedCategory, // Changed parameter
    required this.availableCategories,
    required this.selectedSort,
    required this.onApplyFilters,
    required this.onResetFilters,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  State<ItemWarehousesFilterBottomSheet> createState() =>
      _ItemWarehousesFilterBottomSheetState();
}

class _ItemWarehousesFilterBottomSheetState
    extends State<ItemWarehousesFilterBottomSheet>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // Temporary state for filters
  Category? _tempSelectedCategory; // Changed to single category
  late SortOrder _tempSelectedSort;

  @override
  void initState() {
    super.initState();

    // Initialize temporary state with current values
    _tempSelectedCategory = widget.selectedCategory;
    _tempSelectedSort = widget.selectedSort;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeSheet() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_tempSelectedCategory, _tempSelectedSort);
    _closeSheet();
  }

  void _resetFilters() {
    setState(() {
      _tempSelectedCategory = null;
      _tempSelectedSort = SortOrder.quantityAsc; // Default to quantity sort
    });
  }

  void _resetAndApply() {
    _resetFilters();
    widget.onResetFilters();
    _closeSheet();
  }

  bool get _hasChanges {
    return _tempSelectedCategory?.id != widget.selectedCategory?.id ||
        _tempSelectedSort != widget.selectedSort;
  }

  bool get _hasActiveFilters {
    return _tempSelectedCategory != null ||
        _tempSelectedSort != SortOrder.quantityAsc; // Changed default
  }

  void _selectCategory(Category category) {
    setState(() {
      if (_tempSelectedCategory?.id == category.id) {
        _tempSelectedCategory = null; // Deselect if already selected
      } else {
        _tempSelectedCategory = category; // Select new category
      }
    });
  }

  bool _isCategorySelected(Category category) {
    return _tempSelectedCategory?.id == category.id;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: _closeSheet,
              child: Container(
                color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
              ),
            ),

            // Bottom Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value * 400),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: mediaQuery.size.height * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: widget.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.colorScheme.shadow.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        margin: EdgeInsets.only(top: widget.isTablet ? 16 : 12),
                        width: widget.isTablet ? 48 : 40,
                        height: widget.isTablet ? 5 : 4,
                        decoration: BoxDecoration(
                          color: widget.colorScheme.onSurfaceVariant
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      // Header
                      _buildHeader(),

                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(widget.isTablet ? 24 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Categories Filter Section
                              _buildFilterSection(
                                title: 'Danh mục',
                                icon: Icons.category_outlined,
                                iconColor: Colors.green.shade600,
                                iconBackgroundColor: Colors.green.shade100,
                                child: _buildCategoryFilters(),
                              ),
                              SizedBox(height: widget.isTablet ? 28 : 24),

                              // Sort Filter Section
                              _buildFilterSection(
                                title: 'Sắp xếp theo',
                                icon: Icons.sort_outlined,
                                iconColor: Colors.orange.shade600,
                                iconBackgroundColor: Colors.orange.shade100,
                                child: _buildSortFilters(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: widget.colorScheme.primary.withOpacity(0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(widget.isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: widget.colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.warehouse_outlined,
              color: widget.colorScheme.primary,
              size: widget.isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: widget.isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bộ lọc kho',
                  style: widget.theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Tùy chỉnh hiển thị vật phẩm trong kho',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_hasChanges) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 12 : 10,
                vertical: widget.isTablet ? 6 : 4,
              ),
              decoration: BoxDecoration(
                color: widget.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: widget.isTablet ? 8 : 6,
                    color: widget.colorScheme.primary,
                  ),
                  SizedBox(width: widget.isTablet ? 6 : 4),
                  Text(
                    'Đã thay đổi',
                    style: TextStyle(
                      color: widget.colorScheme.onPrimaryContainer,
                      fontSize: widget.isTablet ? 12 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: widget.isTablet ? 12 : 8),
          ],
          IconButton(
            onPressed: _closeSheet,
            icon: Icon(
              Icons.close_rounded,
              color: widget.colorScheme.onSurfaceVariant,
              size: widget.isTablet ? 22 : 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: widget.colorScheme.surface.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.colorScheme.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: widget.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(widget.isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: widget.isTablet ? 20 : 18,
                  color: iconColor,
                ),
              ),
              SizedBox(width: widget.isTablet ? 12 : 10),
              Text(
                title,
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: widget.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (title == 'Danh mục' && _tempSelectedCategory != null) ...[
                SizedBox(width: widget.isTablet ? 8 : 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isTablet ? 8 : 6,
                    vertical: widget.isTablet ? 4 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: widget.colorScheme.primary,
                      fontSize: widget.isTablet ? 12 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: widget.isTablet ? 16 : 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    if (widget.availableCategories.isEmpty) {
      return Container(
        padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: widget.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: widget.colorScheme.onSurfaceVariant,
              size: widget.isTablet ? 20 : 18,
            ),
            SizedBox(width: widget.isTablet ? 12 : 8),
            Text(
              'Không có danh mục nào',
              style: TextStyle(
                color: widget.colorScheme.onSurfaceVariant,
                fontSize: widget.isTablet ? 14 : 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Clear selection button (only show if category is selected)
        if (_tempSelectedCategory != null) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _tempSelectedCategory = null;
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    size: widget.isTablet ? 18 : 16,
                  ),
                  label: Text(
                    'Bỏ chọn danh mục',
                    style: TextStyle(
                      fontSize: widget.isTablet ? 13 : 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: widget.isTablet ? 8 : 6,
                      horizontal: widget.isTablet ? 12 : 10,
                    ),
                    side: BorderSide(
                      color: widget.colorScheme.outline.withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isTablet ? 16 : 12),
        ],
        // Category chips
        Wrap(
          spacing: widget.isTablet ? 12 : 10,
          runSpacing: widget.isTablet ? 12 : 10,
          children:
              widget.availableCategories
                  .map(
                    (category) => _buildCategoryChip(
                      category: category,
                      isSelected: _isCategorySelected(category),
                      onSelected: () => _selectCategory(category),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildSortFilters() {
    // Only show quantity-related sort options
    final warehouseSortOptions = [
      SortOrder.quantityAsc,
      SortOrder.quantityDesc,
    ];

    return Wrap(
      spacing: widget.isTablet ? 12 : 10,
      runSpacing: widget.isTablet ? 12 : 10,
      children:
          warehouseSortOptions
              .map(
                (sort) => _buildFilterChip(
                  label: sort.label,
                  icon: sort.icon,
                  isSelected: _tempSelectedSort == sort,
                  onSelected: () {
                    setState(() {
                      _tempSelectedSort = sort;
                    });
                  },
                ),
              )
              .toList(),
    );
  }

  Widget _buildCategoryChip({
    required Category category,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Material(
      elevation: isSelected ? 3 : 0,
      borderRadius: BorderRadius.circular(20),
      shadowColor: Colors.green.shade300,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 16 : 14,
            vertical: widget.isTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.green.shade500
                    : widget.colorScheme.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected
                      ? Colors.green.shade400
                      : widget.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: widget.isTablet ? 18 : 16,
                color:
                    isSelected
                        ? Colors.white
                        : widget.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: widget.isTablet ? 8 : 6),
              Text(
                category.name,
                style: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : widget.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: widget.isTablet ? 14 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Material(
      elevation: isSelected ? 4 : 0,
      borderRadius: BorderRadius.circular(24),
      shadowColor: widget.colorScheme.primary.withOpacity(0.3),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 18 : 16,
            vertical: widget.isTablet ? 14 : 12,
          ),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [
                        widget.colorScheme.primary,
                        widget.colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color:
                isSelected
                    ? null
                    : widget.colorScheme.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  isSelected
                      ? widget.colorScheme.primary.withOpacity(0.3)
                      : widget.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: widget.isTablet ? 20 : 18,
                color:
                    isSelected
                        ? Colors.white
                        : widget.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: widget.isTablet ? 8 : 6),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : widget.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: widget.isTablet ? 15 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        widget.isTablet ? 24 : 20,
        widget.isTablet ? 16 : 12,
        widget.isTablet ? 24 : 20,
        widget.isTablet ? 24 : 20,
      ),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: widget.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Reset button (if has active filters)
          if (_hasActiveFilters) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetAndApply,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: widget.isTablet ? 20 : 18,
                ),
                label: Text(
                  'Đặt lại bộ lọc',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: widget.isTablet ? 15 : 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.isTablet ? 16 : 14,
                    horizontal: widget.isTablet ? 24 : 20,
                  ),
                  side: BorderSide(
                    color: widget.colorScheme.outline.withOpacity(0.3),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: widget.colorScheme.surface,
                  foregroundColor: widget.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: widget.isTablet ? 16 : 12),
          ],

          // Main action buttons
          Row(
            children: [
              // Apply Button
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _hasChanges ? _applyFilters : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: widget.isTablet ? 16 : 14,
                      horizontal: widget.isTablet ? 24 : 20,
                    ),
                    backgroundColor:
                        _hasChanges
                            ? widget.colorScheme.primary
                            : widget.colorScheme.surfaceVariant,
                    foregroundColor:
                        _hasChanges
                            ? Colors.white
                            : widget.colorScheme.onSurfaceVariant,
                    elevation: _hasChanges ? 3 : 0,
                    shadowColor: widget.colorScheme.primary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: widget.isTablet ? 20 : 18,
                      ),
                      SizedBox(width: widget.isTablet ? 8 : 6),
                      Text(
                        'Áp dụng',
                        style: widget.theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: widget.isTablet ? 16 : 14,
                          color:
                              _hasChanges
                                  ? Colors.white
                                  : widget.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}