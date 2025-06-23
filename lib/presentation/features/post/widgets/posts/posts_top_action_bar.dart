import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/create_post_button.dart';
import 'package:trao_doi_do_app/presentation/widgets/search_button.dart';
import 'package:trao_doi_do_app/presentation/widgets/search_text_field.dart';

class PostsTopActionBar extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearchVisible;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchToggle;
  final VoidCallback onSearchClear;
  final VoidCallback onFilterPressed;
  final VoidCallback onCreatePressed;
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool hasActiveSearch;
  final bool hasActiveFilters;

  const PostsTopActionBar({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearchVisible,
    required this.onSearchChanged,
    required this.onSearchToggle,
    required this.onSearchClear,
    required this.onFilterPressed,
    required this.onCreatePressed,
    required this.isTablet,
    required this.colorScheme,
    required this.hasActiveSearch,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
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
          // Main action bar
          Row(
            children: [
              // Search Button/Field
              Expanded(
                child: isSearchVisible 
                    ? SearchTextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        onChanged: onSearchChanged,
                        onToggle: onSearchToggle,
                        onClear: onSearchClear,
                        isTablet: isTablet,
                        colorScheme: colorScheme,
                      )
                    : SearchButton(
                        controller: searchController,
                        onToggle: onSearchToggle,
                        onClear: onSearchClear,
                        isTablet: isTablet,
                        colorScheme: colorScheme,
                        hasActiveSearch: hasActiveSearch,
                      ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              
              // Filter Button
              FilterButton(
                onPressed: onFilterPressed,
                isTablet: isTablet,
                colorScheme: colorScheme,
                hasActiveFilters: hasActiveFilters,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              
              // Create Post Button
              CreatePostButton(
                onPressed: onCreatePressed,
                isTablet: isTablet,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool hasActiveFilters;

  const FilterButton({
    super.key,
    required this.onPressed,
    required this.isTablet,
    required this.colorScheme,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: hasActiveFilters ? 2 : 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color:
                hasActiveFilters
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border:
                hasActiveFilters
                    ? Border.all(color: colorScheme.primary.withOpacity(0.3))
                    : null,
          ),
          child: Icon(
            hasActiveFilters ? Icons.filter_alt : Icons.tune,
            color:
                hasActiveFilters
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
            size: isTablet ? 24 : 20,
          ),
        ),
      ),
    );
  }
}
