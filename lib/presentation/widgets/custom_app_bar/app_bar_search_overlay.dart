import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/presentation/widgets/search_suggestions_overlay.dart';

class AppBarSearchOverlay {
  static OverlayEntry? createOverlay({
    required BuildContext context,
    required Function(dynamic) onPostTap,
    required VoidCallback onViewAll,
  }) {
    // final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder:
          (context) => Positioned(
            top: offset.dy + size.height,
            left: 0,
            right: 0,
            bottom: 5,
            child: Container(
              color: Colors.black.withOpacity(0.1),
              child: Material(
                color: Colors.transparent,
                child: Consumer(
                  builder: (context, ref, child) {
                    final searchState = ref.watch(searchSuggestionsProvider);

                    if (searchState.query.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: SearchSuggestionsOverlay(
                        suggestions: searchState.suggestions,
                        isLoading: searchState.isLoading,
                        searchQuery: searchState.query,
                        onPostTap: onPostTap,
                        onViewAll: onViewAll,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
    );
  }
}
