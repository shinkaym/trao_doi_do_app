import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/posts_provider.dart';

class Pagination extends ConsumerWidget {
  final PostsListState state;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const Pagination({
    super.key,
    required this.state,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          PaginationButton(
            icon: Icons.chevron_left,
            enabled: state.currentPage > 1 && !state.isLoadingPage,
            onPressed:
                () => ref.read(postsListProvider.notifier).goToPreviousPage(),
            isTablet: isTablet,
            colorScheme: colorScheme,
          ),

          SizedBox(width: isTablet ? 16 : 12),

          // Page numbers
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageNumbers(context, ref),
              ),
            ),
          ),

          SizedBox(width: isTablet ? 16 : 12),

          // Next button
          PaginationButton(
            icon: Icons.chevron_right,
            enabled:
                state.currentPage < state.totalPage && !state.isLoadingPage,
            onPressed:
                () => ref.read(postsListProvider.notifier).goToNextPage(),
            isTablet: isTablet,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context, WidgetRef ref) {
    List<Widget> pages = [];
    int currentPage = state.currentPage;
    int totalPage = state.totalPage;

    // Logic hiển thị số trang
    int start = (currentPage - 2).clamp(1, totalPage);
    int end = (currentPage + 2).clamp(1, totalPage);

    // Luôn hiển thị trang đầu
    if (start > 1) {
      pages.add(_buildPageButton(1, ref));
      if (start > 2) {
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('...', style: TextStyle(color: colorScheme.onSurface)),
          ),
        );
      }
    }

    // Hiển thị các trang ở giữa
    for (int i = start; i <= end; i++) {
      pages.add(_buildPageButton(i, ref));
    }

    // Luôn hiển thị trang cuối
    if (end < totalPage) {
      if (end < totalPage - 1) {
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('...', style: TextStyle(color: colorScheme.onSurface)),
          ),
        );
      }
      pages.add(_buildPageButton(totalPage, ref));
    }

    return pages;
  }

  Widget _buildPageButton(int page, WidgetRef ref) {
    final isActive = page == state.currentPage;

    return PageButton(
      page: page,
      isActive: isActive,
      isTablet: isTablet,
      colorScheme: colorScheme,
      onTap:
          !state.isLoadingPage && page != state.currentPage
              ? () => ref.read(postsListProvider.notifier).goToPage(page)
              : null,
    );
  }
}

class PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final bool isTablet;
  final ColorScheme colorScheme;

  const PaginationButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isTablet ? 44 : 40,
      height: isTablet ? 44 : 40,
      decoration: BoxDecoration(
        color: enabled ? colorScheme.surface : colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow:
            enabled
                ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            icon,
            size: isTablet ? 20 : 18,
            color:
                enabled
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class PageButton extends StatelessWidget {
  final int page;
  final bool isActive;
  final bool isTablet;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const PageButton({
    super.key,
    required this.page,
    required this.isActive,
    required this.isTablet,
    required this.colorScheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: isTablet ? 44 : 40,
        height: isTablet ? 44 : 40,
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(
                page.toString(),
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}