import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class AppointmentsEmptyState extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final SortOrder selectedSort;
  final VoidCallback onResetFilters;

  const AppointmentsEmptyState({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.selectedSort,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có đang áp dụng bộ lọc không
    final hasActiveFilters = selectedSort != SortOrder.startTimeDesc;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon chính
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: isTablet ? 64 : 48,
              color: colorScheme.primary.withOpacity(0.7),
            ),
          ),

          SizedBox(height: isTablet ? 24 : 20),

          // Tiêu đề chính
          Text(
            'Không có cuộc hẹn nào',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),

          SizedBox(height: isTablet ? 12 : 10),

          // Mô tả
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
            child: Text(
              hasActiveFilters
                  ? 'Không tìm thấy cuộc hẹn nào phù hợp với bộ lọc hiện tại'
                  : 'Chưa có cuộc hẹn nào được tạo.\nHãy đợi người dùng đặt lịch hẹn với bạn.',
              style: TextStyle(
                fontSize: isTablet ? 15 : 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Hiển thị thông tin bộ lọc hiện tại (nếu có)
          if (hasActiveFilters) ...[
            SizedBox(height: isTablet ? 20 : 16),

            Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: isTablet ? 18 : 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Text(
                        'Bộ lọc hiện tại:',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 8 : 6),

                  // Hiển thị bộ lọc sắp xếp đang áp dụng
                  _buildFilterChip(
                    context,
                    'Sắp xếp: ${selectedSort.label}',
                    selectedSort.icon,
                  ),
                ],
              ),
            ),
          ],

          // Nút đặt lại bộ lọc
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

          // Nút hành động phụ (nếu không có bộ lọc)
          if (!hasActiveFilters) ...[
            SizedBox(height: isTablet ? 32 : 24),
            OutlinedButton.icon(
              onPressed: () {
                // Có thể thêm hành động như mở hướng dẫn hoặc làm mới dữ liệu
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Đang làm mới danh sách cuộc hẹn...'),
                    backgroundColor: colorScheme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(Icons.refresh, size: isTablet ? 18 : 16),
              label: Text(
                'Làm mới',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 12 : 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget helper để tạo filter chip
  Widget _buildFilterChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 10,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 14 : 12, color: colorScheme.primary),
          SizedBox(width: isTablet ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
