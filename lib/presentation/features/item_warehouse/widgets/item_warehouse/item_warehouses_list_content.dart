import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/notifiers/old_stock_notifier.dart';
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

  // Helper function để tính số lượng có thể nhận
  int getAvailableForClaim(OldStockItem item) {
    return item.quantity < item.maxClaim ? item.quantity : item.maxClaim;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hiển thị skeleton khi đang loading lần đầu (không có dữ liệu)
    if (oldStockState.isLoading && oldStockState.items.isEmpty) {
      return _buildSkeletonContent();
    }

    // Hiển thị empty state khi không có dữ liệu và không loading
    if (oldStockState.items.isEmpty && !oldStockState.isLoading) {
      return _buildEmptyState();
    }

    // Hiển thị danh sách items (có thể có skeleton cho pagination)
    return _buildItemsList();
  }

  Widget _buildSkeletonContent() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          SizedBox(height: isTablet ? 16 : 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            child: ItemWarehouseSkeletonList(
              isTablet: isTablet,
              colorScheme: colorScheme,
              itemCount: 10,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
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

  Widget _buildItemsList() {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // Top spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),

          // Items List hoặc Skeleton khi loading pagination
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            sliver:
                oldStockState.isLoadingPage || oldStockState.isLoading
                    ? SliverToBoxAdapter(
                      child: ItemWarehouseSkeletonList(
                        isTablet: isTablet,
                        colorScheme: colorScheme,
                        itemCount: 10,
                      ),
                    )
                    : SliverList.separated(
                      itemCount: oldStockState.items.length,
                      itemBuilder: (context, index) {
                        final item = oldStockState.items[index];
                        final availableForClaim = getAvailableForClaim(item);

                        return ItemWarehouseCard(
                          item: item,
                          isTablet: isTablet,
                          theme: theme,
                          colorScheme: colorScheme,
                          onTap: onItemTap,
                          // Chỉ hiển thị nút "Thêm" nếu có thể nhận (availableForClaim > 0)
                          onAddToCart:
                              availableForClaim > 0 ? onAddToCart : null,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: isTablet ? 8 : 6);
                      },
                    ),
          ),

          // Pagination - luôn hiển thị khi có nhiều trang
          if (oldStockState.totalPage > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 6),
                child: ItemWarehousesPagination(
                  state: oldStockState,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
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
