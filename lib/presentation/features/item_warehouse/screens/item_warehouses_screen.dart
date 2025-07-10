import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/usecases/params/old_stock_query.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';
import 'package:trao_doi_do_app/domain/entities/category.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/widgets/item_warehouse/cart_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/widgets/item_warehouse/claim_requests_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/widgets/item_warehouse/item_warehouses_filter_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/widgets/item_warehouse/item_warehouses_list_content.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/widgets/item_warehouse/item_warehouses_top_action_bar.dart';
import 'package:trao_doi_do_app/presentation/widgets/scroll_to_top_button.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class ItemWarehousesScreen extends HookConsumerWidget {
  const ItemWarehousesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oldStockState = ref.watch(oldStockProvider);
    final availableCategories = ref.watch(categoryProvider).categories;

    final searchQuery = useState<String>('');
    final scrollController = useScrollController();
    final searchFocusNode = useFocusNode();
    final isSearchVisible = useState<bool>(false);

    final selectedItems = useState<Map<String, int>>({});

    final debouncer = useMemoized(() => Debouncer());

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    final searchController = useTextEditingController(
      text: oldStockState.query.search ?? '',
    );

    final selectedCategory = useState<Category?>(
      oldStockState.query.categoryID != null
          ? availableCategories.firstWhere(
            (c) => c.id == oldStockState.query.categoryID,
            orElse: () => availableCategories[0],
          )
          : null,
    );

    final selectedSort = useState<SortOrder>(
      oldStockState.query.sort != null && oldStockState.query.order != null
          ? SortOrder.quantitySortOptions.firstWhere(
            (s) =>
                s.sort == oldStockState.query.sort &&
                s.order == oldStockState.query.order,
            orElse: () => SortOrder.quantityAsc,
          )
          : SortOrder.quantityAsc,
    );

    // Cập nhật hàm loadItems
    void loadItems({bool refresh = false}) {
      final query = OldStockQuery(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        categoryID: selectedCategory.value?.id,
        sort: selectedSort.value.sort,
        order: selectedSort.value.order,
        page: refresh ? 1 : oldStockState.currentPage,
      );

      ref
          .read(oldStockProvider.notifier)
          .loadOldStock(newQuery: query, refresh: refresh);
    }

    // Lấy thông tin item từ state để kiểm tra quantity và maxClaim
    OldStockItem? getItemById(int itemId) {
      if (oldStockState.items.isNotEmpty) {
        try {
          return oldStockState.items.firstWhere(
            (item) => item.itemID == itemId,
          );
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Helper function để tính số lượng có thể nhận
    int getAvailableForClaim(OldStockItem item) {
      return item.quantity < item.maxClaim ? item.quantity : item.maxClaim;
    }

    void showQuantityExceededSnackBar(
      String itemName,
      int availableQuantity,
      String reason,
    ) {
      String message;
      if (reason == 'maxClaim') {
        message = 'Chỉ được phép nhận tối đa $availableQuantity "$itemName"';
      } else {
        message = 'Chỉ còn $availableQuantity "$itemName" trong kho';
      }

      context.showInfoSnackBar(message);
    }

    void addToCart(OldStockItem item) {
      final currentItems = Map<String, int>.from(selectedItems.value);
      final itemKey = '${item.itemID}_${item.itemName}';
      final currentQuantityInCart = currentItems[itemKey] ?? 0;
      final availableForClaim = getAvailableForClaim(item);

      // Kiểm tra nếu thêm 1 sẽ vượt quá số lượng có thể nhận
      if (currentQuantityInCart + 1 > availableForClaim) {
        // Xác định lý do giới hạn
        String reason = item.quantity < item.maxClaim ? 'quantity' : 'maxClaim';
        showQuantityExceededSnackBar(item.itemName, availableForClaim, reason);
        return;
      }

      currentItems[itemKey] = currentQuantityInCart + 1;
      selectedItems.value = currentItems;
    }

    void updateItemQuantity(String itemKey, int quantity) {
      if (quantity <= 0) {
        final currentItems = Map<String, int>.from(selectedItems.value);
        currentItems.remove(itemKey);
        selectedItems.value = currentItems;
        return;
      }

      // Lấy itemID từ itemKey để kiểm tra quantity và maxClaim
      final itemIdStr = itemKey.split('_').first;
      final itemId = int.tryParse(itemIdStr);

      if (itemId != null) {
        final item = getItemById(itemId);
        if (item != null) {
          final availableForClaim = getAvailableForClaim(item);

          // Kiểm tra nếu quantity yêu cầu vượt quá số lượng có thể nhận
          if (quantity > availableForClaim) {
            // Xác định lý do giới hạn
            String reason =
                item.quantity < item.maxClaim ? 'quantity' : 'maxClaim';
            showQuantityExceededSnackBar(
              item.itemName,
              availableForClaim,
              reason,
            );
            return;
          }
        }
      }

      final currentItems = Map<String, int>.from(selectedItems.value);
      currentItems[itemKey] = quantity;
      selectedItems.value = currentItems;
    }

    void showCartBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => CartBottomSheet(
              selectedItems: selectedItems.value,
              onUpdateQuantity: updateItemQuantity,
              onConfirm: () {
                selectedItems.value = {};

                loadItems(refresh: true);
              },
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
              getItemById: getItemById,
            ),
      );
    }

    void showClaimRequestsBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => ClaimRequestsBottomSheet(
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
              getItemById: getItemById,
              onUpdated: () {},
            ),
      );
    }

    void handleSearch(String query) {
      debouncer.debounce(
        duration: const Duration(milliseconds: 500),
        onDebounce: () {
          searchQuery.value = query;
          loadItems(refresh: true);
        },
      );
    }

    void handleApplyFilters(Category? category, SortOrder sort) {
      selectedCategory.value = category;
      selectedSort.value = sort;
      loadItems(refresh: true);
    }

    void handleRefresh() {
      loadItems(refresh: true);
    }

    void handleItemTap(OldStockItem item) {
      // context.pushNamed(
      //   'item-warehouse-detail',
      //   pathParameters: {'id': item.itemID.toString()},
      // );
    }

    void resetFilters() {
      selectedCategory.value = null;
      selectedSort.value = SortOrder.quantityAsc;
      loadItems(refresh: true);
    }

    void resetSearch() {
      searchQuery.value = '';
      searchController.clear();
      isSearchVisible.value = false;
      loadItems(refresh: true);
    }

    void resetAll() {
      searchQuery.value = '';
      selectedCategory.value = null;
      selectedSort.value = SortOrder.quantityAsc;
      searchController.clear();
      isSearchVisible.value = false;
      loadItems(refresh: true);
    }

    void showFilterBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => ItemWarehousesFilterBottomSheet(
              selectedCategory: selectedCategory.value,
              availableCategories: availableCategories,
              selectedSort: selectedSort.value,
              onApplyFilters: handleApplyFilters,
              onResetFilters: resetFilters,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
            ),
      );
    }

    void toggleSearch() {
      isSearchVisible.value = !isSearchVisible.value;
      if (isSearchVisible.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          searchFocusNode.requestFocus();
        });
      } else {
        searchFocusNode.unfocus();
        if (searchController.text.isEmpty) {
          resetSearch();
        }
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (oldStockState.items.isEmpty) {
          loadItems();
        }
      });
      return () => debouncer.cancel();
    }, []);

    return SmartScaffold(
      appBarType: AppBarType.standard,
      appBarActions: [
        Container(
          margin: EdgeInsets.only(right: isTablet ? 8 : 4),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.list_alt_outlined,
                color: colorScheme.primary,
                size: isTablet ? 22 : 20,
              ),
            ),
            onPressed: showClaimRequestsBottomSheet,
            tooltip: 'Danh sách món đồ đã yêu cầu',
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: isTablet ? 8 : 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: colorScheme.primary,
                    size: isTablet ? 22 : 20,
                  ),
                ),
                onPressed: showCartBottomSheet,
                tooltip: 'Giỏ đồ',
              ),
              if (selectedItems.value.isNotEmpty)
                Positioned(
                  right: isTablet ? 8 : 6,
                  top: isTablet ? 8 : 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 8 : 6,
                      vertical: isTablet ? 4 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: BoxConstraints(
                      minWidth: isTablet ? 20 : 16,
                      minHeight: isTablet ? 20 : 16,
                    ),
                    child: Text(
                      selectedItems.value.values
                          .fold(0, (sum, qty) => sum + qty)
                          .toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 11 : 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                ItemWarehousesTopActionBar(
                  searchController: searchController,
                  searchFocusNode: searchFocusNode,
                  isSearchVisible: isSearchVisible.value,
                  onSearchChanged: handleSearch,
                  onSearchToggle: toggleSearch,
                  onSearchClear: resetSearch,
                  onFilterPressed: showFilterBottomSheet,
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                  hasActiveSearch: searchQuery.value.isNotEmpty,
                  hasActiveFilters:
                      selectedCategory.value != null ||
                      selectedSort.value != SortOrder.quantityAsc,
                ),
                Expanded(
                  child: ItemWarehousesListContent(
                    oldStockState: oldStockState,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    searchQuery: searchQuery.value,
                    selectedCategories:
                        selectedCategory.value != null
                            ? [selectedCategory.value!]
                            : [],
                    selectedSort: selectedSort.value,
                    onItemTap: handleItemTap,
                    onRefresh: handleRefresh,
                    onResetFilters: resetAll,
                    scrollController: scrollController,
                    onAddToCart: addToCart,
                  ),
                ),
              ],
            ),
            ScrollToTopButton(
              scrollController: scrollController,
              isTablet: isTablet,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}
