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
    final searchController = useTextEditingController();
    final selectedCategory = useState<Category?>(null);
    final selectedSort = useState<SortOrder>(SortOrder.quantityAsc);
    final searchQuery = useState<String>('');
    final scrollController = useScrollController();
    final searchFocusNode = useFocusNode();
    final isSearchVisible = useState<bool>(false);

    final selectedItems = useState<Map<String, int>>({});

    final debouncer = useMemoized(() => Debouncer());

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final oldStockState = ref.watch(oldStockProvider);

    final availableCategories = ref.watch(categoryProvider).categories;

    // Lấy thông tin item từ state để kiểm tra quantity
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

    void showQuantityExceededSnackBar(String itemName, int availableQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Chỉ còn $availableQuantity "$itemName" trong kho',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }

    void addToCart(OldStockItem item) {
      final currentItems = Map<String, int>.from(selectedItems.value);
      final itemKey = '${item.itemID}_${item.itemName}';
      final currentQuantityInCart = currentItems[itemKey] ?? 0;

      // Kiểm tra nếu thêm 1 sẽ vượt quá số lượng có sẵn
      if (currentQuantityInCart + 1 > item.quantity) {
        showQuantityExceededSnackBar(item.itemName, item.quantity);
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

      // Lấy itemID từ itemKey để kiểm tra quantity
      final itemIdStr = itemKey.split('_').first;
      final itemId = int.tryParse(itemIdStr);

      if (itemId != null) {
        final item = getItemById(itemId);
        if (item != null) {
          // Kiểm tra nếu quantity yêu cầu vượt quá số lượng có sẵn
          if (quantity > item.quantity) {
            showQuantityExceededSnackBar(item.itemName, item.quantity);
            return;
          }
        }
      }

      final currentItems = Map<String, int>.from(selectedItems.value);
      currentItems[itemKey] = quantity;
      selectedItems.value = currentItems;
    }

    void loadItems({bool refresh = false}) {
      final query = OldStockQuery(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        categoryID: selectedCategory.value?.id,
        sort: selectedSort.value.sort,
        order: selectedSort.value.order,
        page: refresh ? 1 : 1,
      );

      ref
          .read(oldStockProvider.notifier)
          .loadOldStock(newQuery: query, refresh: refresh);
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
      context.pushNamed(
        'item-warehouse-detail',
        pathParameters: {'id': item.itemID.toString()},
      );
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
        loadItems();
      });
      return () {
        debouncer.cancel();
      };
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
            tooltip: 'Danh sách yêu cầu',
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
