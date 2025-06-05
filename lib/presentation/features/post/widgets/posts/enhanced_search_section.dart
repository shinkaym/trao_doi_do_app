import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/posts_screen.dart';

class EnhancedSearchSection extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final WidgetRef ref;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final PostsState postsState;
  final PostsNotifier postsNotifier;

  const EnhancedSearchSection({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.ref,
    required this.searchController,
    required this.searchFocusNode,
    required this.postsState,
    required this.postsNotifier,
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: (query) {
                    postsNotifier.updateSearchQuery(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bài đăng...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (postsState.searchQuery.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              searchController.clear();
                              postsNotifier.updateSearchQuery('');
                              searchFocusNode.unfocus();
                            },
                            icon: const Icon(Icons.clear),
                            tooltip: 'Xóa tìm kiếm',
                          ),
                      ],
                    ),
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
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...PostType.values.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: postsState.selectedType == type,
                      onSelected: (_) {
                        postsNotifier.updateTypeFilter(type);
                      },
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
                      checkmarkColor: colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                ...SortOrder.values.map(
                  (sort) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: postsState.selectedSort == sort,
                      onSelected: (_) {
                        postsNotifier.updateSortFilter(sort);
                      },
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(sort.icon, size: isTablet ? 18 : 16),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(sort.label),
                        ],
                      ),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.secondaryContainer,
                      checkmarkColor: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (postsState.displayedPosts.isNotEmpty || postsState.isLoading) ...[
            SizedBox(height: isTablet ? 12 : 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trang ${postsState.currentPage}/${postsState.totalPages}',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (postsState.isLoading)
                  SizedBox(
                    width: isTablet ? 16 : 12,
                    height: isTablet ? 16 : 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
