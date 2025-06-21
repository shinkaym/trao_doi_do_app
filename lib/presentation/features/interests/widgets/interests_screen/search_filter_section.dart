import 'package:flutter/material.dart';

class SearchFilterSection extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String currentSortOrder;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function(String, String) onSortFilter;

  const SearchFilterSection({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.currentSortOrder,
    required this.searchController,
    required this.onSearch,
    required this.onSortFilter,
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
          TextField(
            controller: searchController,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bài đăng quan tâm...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  searchController.text.isNotEmpty
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
                vertical: isTablet ? 6 : 4,
              ),
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Sort Options
          Row(
            children: [
              ChoiceChip(
                selected: currentSortOrder == 'DESC',
                onSelected: (selected) {
                  if (selected) onSortFilter('createdAt', 'DESC');
                },
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isTablet ? 18 : 16,
                      color:
                          currentSortOrder == 'DESC'
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      'Mới nhất',
                      style: TextStyle(
                        color:
                            currentSortOrder == 'DESC'
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.secondary,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              ChoiceChip(
                selected: currentSortOrder == 'ASC',
                onSelected: (selected) {
                  if (selected) onSortFilter('createdAt', 'ASC');
                },
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: isTablet ? 18 : 16,
                      color:
                          currentSortOrder == 'ASC'
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      'Cũ nhất',
                      style: TextStyle(
                        color:
                            currentSortOrder == 'ASC'
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
