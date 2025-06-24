import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/item_warehouse.dart';

class ItemWarehouseCard extends StatelessWidget {
  final OldStockItem item;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final void Function(OldStockItem) onTap;
  final void Function(OldStockItem)? onAddToCart;

  const ItemWarehouseCard({
    super.key,
    required this.item,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => onTap(item),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image
              _buildItemImage(),
              SizedBox(width: isTablet ? 16 : 12),

              // Item Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItemHeader(),
                    SizedBox(height: isTablet ? 8 : 6),
                    _buildItemDescription(),
                    SizedBox(height: isTablet ? 12 : 8),
                    _buildItemStats(),
                  ],
                ),
              ),

              // Add to Cart Button
              if (onAddToCart != null && item.quantity > 0)
                _buildAddToCartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    final imageSize = isTablet ? 80.0 : 64.0;

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceVariant,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildImageWidget(),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (item.itemImage.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(item.itemImage);

      if (imageBytes != null) {
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colorScheme.surfaceVariant,
              child: Icon(
                Icons.inventory_2_outlined,
                size: isTablet ? 32 : 24,
                color: theme.hintColor,
              ),
            );
          },
        );
      }
    }

    return Container(
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.inventory_2_outlined,
        size: isTablet ? 32 : 24,
        color: theme.hintColor,
      ),
    );
  }

  Widget _buildItemHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Name
        Text(
          item.itemName,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: isTablet ? 6 : 4),

        // Category
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 10 : 8,
            vertical: isTablet ? 4 : 3,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            item.categoryName,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemDescription() {
    if (item.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      item.description,
      style: TextStyle(
        fontSize: isTablet ? 14 : 12,
        color: colorScheme.onSurface.withOpacity(0.8),
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildItemStats() {
    return Row(
      children: [
        // Quantity
        _buildStatItem(
          Icons.inventory_outlined,
          'SL: ${item.quantity}',
          item.quantity > 0 ? Colors.green.shade600 : Colors.orange.shade600,
        ),

        SizedBox(width: isTablet ? 12 : 8),

        // Claim Requests
        if (item.claimItemRequests > 0)
          _buildStatItem(
            Icons.person_outline,
            '${item.claimItemRequests} yêu cầu',
            Colors.blue.shade600,
          ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 8,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 14 : 12, color: color),
          SizedBox(width: isTablet ? 4 : 3),
          Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      margin: EdgeInsets.only(left: isTablet ? 12 : 8),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onAddToCart!(item),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.add_shopping_cart_outlined,
                  color: colorScheme.primary,
                  size: isTablet ? 22 : 18,
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Text(
            'Thêm',
            style: TextStyle(
              fontSize: isTablet ? 10 : 8,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
