import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/presentation/features/post/notifiers/posts_notifier.dart';

class PostsPagination extends HookConsumerWidget {
  final PostsListState state;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const PostsPagination({
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
        vertical: isTablet ? 12 : 8,
      ),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          PostsPaginationButton(
            icon: Icons.chevron_left,
            enabled: state.currentPage > 1,
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
          PostsPaginationButton(
            icon: Icons.chevron_right,
            enabled: state.currentPage < state.totalPage,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '...',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '...',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
      onTap: () => ref.read(postsListProvider.notifier).goToPage(page),
    );
  }
}

class PostsPaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final bool isTablet;
  final ColorScheme colorScheme;

  const PostsPaginationButton({
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
        // Sử dụng nền trong suốt với độ mờ
        color:
            enabled
                ? colorScheme.surface.withOpacity(0.9)
                : colorScheme.surfaceVariant.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        // Giữ shadow nhẹ để tạo độ sâu
        boxShadow:
            enabled
                ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.15),
                    blurRadius: 6,
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
          color:
              isActive
                  ? colorScheme.primary.withOpacity(0.9)
                  : colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isActive
                    ? colorScheme.primary.withOpacity(0.7)
                    : colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.15),
              blurRadius: 6,
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
                  color:
                      isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
