import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';

class AppBarTitle extends ConsumerWidget {
  final String title;
  final bool isSearchMode;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String? searchHint;
  final Function(String) onSearchChanged;
  final Function(String) onSearchSubmitted;
  final VoidCallback onSearchClear;
  final Animation<double> searchAnimation;
  final bool isTablet;
  final bool isDark;
  final Color appBarBgColor;
  final Color appBarFgColor;

  const AppBarTitle({
    super.key,
    required this.title,
    required this.isSearchMode,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchHint,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onSearchClear,
    required this.searchAnimation,
    required this.isTablet,
    required this.isDark,
    required this.appBarBgColor,
    required this.appBarFgColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSearchMode) {
      return _buildSearchField();
    }

    return _buildDynamicTitle(ref);
  }

  Widget _buildSearchField() {
    return AnimatedBuilder(
      animation: searchAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(
            right: isTablet ? 16 : 12,
            top: isTablet ? 12 : 8,
            bottom: isTablet ? 12 : 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: isTablet ? 46 : 40,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    style: TextStyle(
                      color: appBarFgColor,
                      fontSize: isTablet ? 16 : 14,
                    ),
                    decoration: InputDecoration(
                      hintText: searchHint,
                      hintStyle: TextStyle(
                        color: appBarFgColor.withOpacity(0.6),
                        fontSize: isTablet ? 16 : 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isTablet ? 14 : 12,
                      ),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: appBarFgColor.withOpacity(0.6),
                                  size: isTablet ? 22 : 20,
                                ),
                                onPressed: onSearchClear,
                              )
                              : Icon(
                                Icons.search_rounded,
                                color: appBarFgColor.withOpacity(0.6),
                                size: isTablet ? 22 : 20,
                              ),
                    ),
                    onChanged: onSearchChanged,
                    onSubmitted: onSearchSubmitted,
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicTitle(WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoggedIn && authState.user != null) {
      final user = authState.user!;
      final emailPrefix = user.email.split('@').first;
      final displayName = user.fullName;

      return Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$emailPrefix\n$displayName',
              style: TextStyle(
                color: appBarFgColor,
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: appBarFgColor,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
