import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class ItemWarehousesEmptyState extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String searchQuery;
  final List<Category> selectedCategories;
  final SortOrder selectedSort;
  final VoidCallback onResetFilters;

  const ItemWarehousesEmptyState({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.searchQuery,
    required this.selectedCategories,
    required this.selectedSort,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có đang áp dụng bộ lọc không
    final hasActiveFilters =
        searchQuery.isNotEmpty ||
        selectedCategories.isNotEmpty ||
        (selectedSort != SortOrder.quantityDesc &&
            selectedSort != SortOrder.quantityAsc);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: isTablet ? 80 : 64,
            color: theme.hintColor,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Không có đồ cũ nào',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            hasActiveFilters
                ? 'Không tìm thấy kết quả phù hợp với bộ lọc'
                : 'Chưa có đồ cũ nào trong kho',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),

          // Hiển thị thông tin về bộ lọc đang áp dụng
          if (hasActiveFilters) ...[
            SizedBox(height: isTablet ? 16 : 12),
            _buildActiveFiltersInfo(),
          ],

          // Hiển thị nút đặt lại bộ lọc nếu có bộ lọc đang áp dụng
          if (hasActiveFilters) ...[
            SizedBox(height: isTablet ? 24 : 20),
            ElevatedButton.icon(
              onPressed: onResetFilters,
              icon: Icon(Icons.refresh, size: isTablet ? 20 : 18),
              label: Text(
                'Đặt lại bộ lọc',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFiltersInfo() {
    final List<Widget> filterChips = [];

    // Search query chip
    if (searchQuery.isNotEmpty) {
      filterChips.add(
        _buildFilterChip('Tìm kiếm: "$searchQuery"', Icons.search),
      );
    }

    // Categories chips
    for (final category in selectedCategories) {
      filterChips.add(
        _buildFilterChip('Danh mục: ${category.name}', Icons.category_outlined),
      );
    }

    // Sort chip (only if not default)
    if (selectedSort != SortOrder.quantityDesc &&
        selectedSort != SortOrder.quantityAsc) {
      filterChips.add(
        _buildFilterChip('Sắp xếp: ${selectedSort.label}', selectedSort.icon),
      );
    }

    if (filterChips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      child: Column(
        children: [
          Text(
            'Bộ lọc đang áp dụng:',
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Wrap(
            spacing: isTablet ? 8 : 6,
            runSpacing: isTablet ? 6 : 4,
            alignment: WrapAlignment.center,
            children: filterChips,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 10,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isTablet ? 14 : 12,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: isTablet ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
