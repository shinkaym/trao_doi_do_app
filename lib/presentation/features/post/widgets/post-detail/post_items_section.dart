import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';

class PostItemsSection extends StatelessWidget {
  final List<ItemDetail> items;

  const PostItemsSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đồ vật',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ...items.map(
            (item) => _buildItemCard(item, isTablet, theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    ItemDetail item,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.image.isNotEmpty
                  ? _buildBase64Image(item.image)
                  : Icon(
                      Icons.inventory_2,
                      color: colorScheme.primary,
                      size: 20,
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      item.categoryName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.currentQuantity}/${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Indicator
          Container(
            width: 6,
            height: 32,
            decoration: BoxDecoration(
              color: _getStatusColor(item.currentQuantity, item.quantity),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBase64Image(String base64String) {
    if (base64String.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(base64String);

      if (imageBytes != null) {
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: const Icon(
                Icons.broken_image,
                size: 20,
                color: Colors.grey,
              ),
            );
          },
        );
      }
    }

    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
    );
  }

  Color _getStatusColor(int current, int total) {
    if (total == 0) return Colors.grey;

    double percentage = current / total;

    if (percentage >= 0.7) {
      return Colors.green;
    } else if (percentage >= 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}