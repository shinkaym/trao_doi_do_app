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
        selectedSort != SortOrder.quantityAsc;

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
}
