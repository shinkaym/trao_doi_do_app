import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';

class SearchSuggestionsOverlay extends StatelessWidget {
  final List<Post> suggestions;
  final bool isLoading;
  final Function(Post) onPostTap;
  final VoidCallback onViewAll;
  final String searchQuery;

  const SearchSuggestionsOverlay({
    super.key,
    required this.suggestions,
    required this.isLoading,
    required this.onPostTap,
    required this.onViewAll,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    if (isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ),
        ),
      );
    }

    if (suggestions.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          height: 120,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: isTablet ? 32 : 28,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                SizedBox(height: 8),
                Text(
                  'Không tìm thấy kết quả phù hợp',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: isTablet ? 20 : 18,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kết quả tìm kiếm cho "$searchQuery"',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Suggestions List
          Container(
            constraints: BoxConstraints(maxHeight: isTablet ? 400 : 300),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final post = suggestions[index];
                return _SuggestionItem(
                  post: post,
                  onTap: () => onPostTap(post),
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                  theme: theme,
                  isLast: index == suggestions.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final bool isLast;

  const _SuggestionItem({
    required this.post,
    required this.onTap,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          border:
              isLast
                  ? null
                  : Border(
                    bottom: BorderSide(
                      color: colorScheme.onSurface.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                child:
                    post.images.isNotEmpty
                        ? _buildImage(post.images.first)
                        : _buildPlaceholder(),
              ),
            ),

            SizedBox(width: isTablet ? 12 : 10),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    post.description,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.createdAt != null) ...[
                    SizedBox(height: 4),
                    Text(
                      TimeUtils.formatTimeAgo(post.createdAt!),
                      style: TextStyle(
                        fontSize: isTablet ? 10 : 9,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: isTablet ? 16 : 14,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageData) {
    if (imageData.startsWith('data:')) {
      try {
        final bytes = Base64Utils.decodeImageFromBase64(imageData);
        if (bytes != null) {
          return Image.memory(
            bytes,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    return Image.network(
      imageData,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: isTablet ? 24 : 20,
        color: theme.hintColor,
      ),
    );
  }
}
