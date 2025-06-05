import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/posts_screen.dart';

class PaginationSection extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final PostsState postsState;
  final PostsNotifier postsNotifier;

  const PaginationSection({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    required this.postsState,
    required this.postsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                postsState.currentPage > 1 ? postsNotifier.previousPage : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Trang trước',
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageNumbers(
                  postsState.currentPage,
                  postsState.totalPages,
                  postsNotifier,
                  isTablet,
                  colorScheme,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed:
                postsState.currentPage < postsState.totalPages
                    ? postsNotifier.nextPage
                    : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Trang sau',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(
    int currentPage,
    int totalPages,
    PostsNotifier postsNotifier,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    List<Widget> pageNumbers = [];

    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > 7) {
      if (currentPage <= 4) {
        endPage = 7;
      } else if (currentPage >= totalPages - 3) {
        startPage = totalPages - 6;
      } else {
        startPage = currentPage - 3;
        endPage = currentPage + 3;
      }
    }

    if (startPage > 1) {
      pageNumbers.add(
        _buildPageButton(1, currentPage, postsNotifier, isTablet, colorScheme),
      );
      if (startPage > 2) {
        pageNumbers.add(_buildEllipsis(isTablet));
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(
        _buildPageButton(i, currentPage, postsNotifier, isTablet, colorScheme),
      );
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageNumbers.add(_buildEllipsis(isTablet));
      }
      pageNumbers.add(
        _buildPageButton(
          totalPages,
          currentPage,
          postsNotifier,
          isTablet,
          colorScheme,
        ),
      );
    }

    return pageNumbers;
  }

  Widget _buildPageButton(
    int page,
    int currentPage,
    PostsNotifier postsNotifier,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    final isSelected = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => postsNotifier.goToPage(page),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: isTablet ? 40 : 32,
            height: isTablet ? 40 : 32,
            alignment: Alignment.center,
            child: Text(
              '$page',
              style: TextStyle(
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text('...', style: TextStyle(fontSize: isTablet ? 14 : 12)),
    );
  }
}
