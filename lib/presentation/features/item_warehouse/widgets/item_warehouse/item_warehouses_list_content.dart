import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/providers/old_stock_provider.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/widgets/item_warehouse/item_warehouse_card.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/widgets/item_warehouse/item_warehouse_skeleton.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/widgets/item_warehouse/item_warehouses_empty_state.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/widgets/item_warehouse/item_warehouses_pagination.dart';

class ItemWarehousesListContent extends HookConsumerWidget {
  final OldStockState oldStockState;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String searchQuery;
  final List<Category> selectedCategories;
  final SortOrder selectedSort;
  final Function(OldStockItem) onItemTap;
  final VoidCallback onRefresh;
  final VoidCallback onResetFilters;
  final ScrollController scrollController;
  final Function(OldStockItem)? onAddToCart;

  const ItemWarehousesListContent({
    super.key,
    required this.oldStockState,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.searchQuery,
    required this.selectedCategories,
    required this.selectedSort,
    required this.onItemTap,
    required this.onRefresh,
    required this.onResetFilters,
    required this.scrollController,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (oldStockState.isLoading && oldStockState.items.isEmpty) {
      return SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            SizedBox(height: isTablet ? 16 : 8),
            ItemWarehouseSkeletonList(
              isTablet: isTablet,
              colorScheme: colorScheme,
              itemCount: 10,
            ),
            SizedBox(height: isTablet ? 24 : 16),
          ],
        ),
      );
    }

    // Hiển thị empty state - FIX: Sử dụng LayoutBuilder để lấy chiều cao available
    if (oldStockState.items.isEmpty && !oldStockState.isLoading) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: scrollController,
              physics:
                  const AlwaysScrollableScrollPhysics(), // Cho phép pull to refresh
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight, // Đảm bảo chiều cao tối thiểu
                ),
                child: IntrinsicHeight(
                  child: ItemWarehousesEmptyState(
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    searchQuery: searchQuery,
                    selectedCategories: selectedCategories,
                    selectedSort: selectedSort,
                    onResetFilters: onResetFilters,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // Top spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),

          // Items List
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            sliver: SliverList.separated(
              itemCount: oldStockState.items.length,
              itemBuilder: (context, index) {
                final item = oldStockState.items[index];
                return ItemWarehouseCard(
                  item: item,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  onTap: onItemTap,
                  onAddToCart: onAddToCart,
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: isTablet ? 8 : 6);
              },
            ),
          ),

          // Loading more indicator
          if (oldStockState.isLoadingMore)
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: isTablet ? 20 : 16,
                      height: isTablet ? 20 : 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Text(
                      'Đang tải thêm...',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Pagination - integrated in the scroll view
          if (oldStockState.totalPage > 1 && oldStockState.items.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 6),
                child: ItemWarehousesPagination(
                  state: oldStockState,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  onPageChanged: (page) {
                    ref.read(oldStockProvider.notifier).goToPage(page);
                  },
                  onPreviousPage: () {
                    ref.read(oldStockProvider.notifier).goToPreviousPage();
                  },
                  onNextPage: () {
                    ref.read(oldStockProvider.notifier).goToNextPage();
                  },
                  onFirstPage: () {
                    ref.read(oldStockProvider.notifier).goToFirstPage();
                  },
                  onLastPage: () {
                    ref.read(oldStockProvider.notifier).goToLastPage();
                  },
                ),
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 100 : 80)),
        ],
      ),
    );
  }
}
