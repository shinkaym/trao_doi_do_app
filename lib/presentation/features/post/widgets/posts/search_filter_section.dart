import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';

class SearchFilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final PostType selectedType;
  final SortOrder selectedSort;
  final String searchQuery;
  final Function(String) onSearch;
  final Function(PostType) onTypeFilter;
  final Function(SortOrder) onSortFilter;
  final int postsCount;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const SearchFilterSection({
    super.key,
    required this.searchController,
    required this.selectedType,
    required this.selectedSort,
    required this.searchQuery,
    required this.onSearch,
    required this.onTypeFilter,
    required this.onSortFilter,
    required this.postsCount,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          SizedBox(height: isTablet ? 16 : 12),
          // Filter Chips
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: onSearch,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm bài đăng...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            searchQuery.isNotEmpty
                ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    onSearch('');
                  },
                  icon: const Icon(Icons.clear),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 16 : 12,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Type Filter
          ...PostType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selectedType == type,
                onSelected: (_) => onTypeFilter(type),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon, size: isTablet ? 18 : 16),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(type.label),
                  ],
                ),
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.secondary,
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          // Sort Filter
          ...SortOrder.values.map(
            (sort) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selectedSort == sort,
                onSelected: (_) => onSortFilter(sort),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(sort.icon, size: isTablet ? 18 : 16),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(sort.label),
                  ],
                ),
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
