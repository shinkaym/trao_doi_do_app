import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class SearchFilterSection extends StatefulWidget {
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
  final Duration debounceDuration; // Thời gian delay cho debounce

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
    this.debounceDuration = const Duration(milliseconds: 500), // Default 500ms
  });

  @override
  State<SearchFilterSection> createState() => _SearchFilterSectionState();
}

class _SearchFilterSectionState extends State<SearchFilterSection> {
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    // Khởi tạo debouncer
    _debouncer = Debouncer();
  }

  void _handleSearchChange(String query) {
    // Sử dụng debouncer để delay việc gọi onSearch
    _debouncer.debounce(
      duration: widget.debounceDuration,
      onDebounce: () {
        widget.onSearch(query);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: widget.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          SizedBox(height: widget.isTablet ? 16 : 12),
          // Filter Chips
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: widget.searchController,
      onChanged: _handleSearchChange, // Sử dụng hàm debounced
      decoration: InputDecoration(
        hintText: 'Tìm kiếm bài đăng...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            widget.searchQuery.isNotEmpty
                ? IconButton(
                  onPressed: () {
                    widget.searchController.clear();
                    // Cancel debouncer và gọi onSearch ngay lập tức khi clear
                    _debouncer.cancel();
                    widget.onSearch('');
                  },
                  icon: const Icon(Icons.clear),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: widget.colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.isTablet ? 20 : 16,
          vertical: widget.isTablet ? 6 : 4,
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
                selected: widget.selectedType == type,
                onSelected: (_) => widget.onTypeFilter(type),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      size: widget.isTablet ? 18 : 16,
                      color:
                          widget.selectedType == type
                              ? widget.colorScheme.onPrimaryContainer
                              : widget.colorScheme.onSurface,
                    ),
                    SizedBox(width: widget.isTablet ? 6 : 4),
                    Text(
                      type.label,
                      style: TextStyle(
                        color:
                            widget.selectedType == type
                                ? widget.colorScheme.onPrimaryContainer
                                : widget.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                backgroundColor: widget.colorScheme.surface,
                selectedColor: widget.colorScheme.primaryContainer,
                checkmarkColor: widget.colorScheme.secondary,
                labelStyle: TextStyle(
                  color:
                      widget.selectedType == type
                          ? widget.colorScheme.onPrimaryContainer
                          : widget.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SizedBox(width: widget.isTablet ? 16 : 12),
          // Sort Filter
          ...SortOrder.values.map(
            (sort) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: widget.selectedSort == sort,
                onSelected: (_) => widget.onSortFilter(sort),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sort.icon,
                      size: widget.isTablet ? 18 : 16,
                      color:
                          widget.selectedSort == sort
                              ? widget.colorScheme.onPrimaryContainer
                              : widget.colorScheme.onSurface,
                    ),
                    SizedBox(width: widget.isTablet ? 6 : 4),
                    Text(sort.label),
                  ],
                ),
                backgroundColor: widget.colorScheme.surface,
                selectedColor: widget.colorScheme.primaryContainer,
                checkmarkColor: widget.colorScheme.secondary,
                labelStyle: TextStyle(
                  color:
                      widget.selectedSort == sort
                          ? widget.colorScheme.onPrimaryContainer
                          : widget.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
