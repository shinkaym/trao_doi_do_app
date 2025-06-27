import 'package:flutter/material.dart';

class ItemWarehouseSkeleton extends StatefulWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const ItemWarehouseSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  State<ItemWarehouseSkeleton> createState() => _ItemWarehouseSkeletonState();
}

class _ItemWarehouseSkeletonState extends State<ItemWarehouseSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Màu base skeleton - đậm hơn
        final baseColor = widget.colorScheme.brightness == Brightness.dark 
            ? Colors.grey[800]! 
            : Colors.grey[300]!;
            
        final highlightColor = widget.colorScheme.brightness == Brightness.dark 
            ? Colors.grey[700]! 
            : Colors.grey[100]!;
            
        return Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _animation.value, 0.0),
              end: Alignment(0.0 + _animation.value, 0.0),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.isTablet ? 16 : 12),
        side: BorderSide(
          color: widget.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image Skeleton - Match exact card layout
            _buildImageSkeleton(),
            SizedBox(width: widget.isTablet ? 16 : 12),

            // Item Info Skeleton - Match exact card layout
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemHeaderSkeleton(),
                  SizedBox(height: widget.isTablet ? 8 : 6),
                  _buildItemDescriptionSkeleton(),
                  SizedBox(height: widget.isTablet ? 12 : 8),
                  _buildItemStatsSkeleton(),
                ],
              ),
            ),

            // Add to Cart Button Skeleton - Match exact card layout
            _buildAddToCartButtonSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSkeleton() {
    final imageSize = widget.isTablet ? 80.0 : 64.0;

    return _buildShimmerContainer(
      width: imageSize,
      height: imageSize,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildItemHeaderSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Name - 2 lines to match real card
        _buildShimmerContainer(
          width: double.infinity,
          height: widget.isTablet ? 20 : 18,
          borderRadius: BorderRadius.circular(4),
        ),
        SizedBox(height: widget.isTablet ? 6 : 4),
        _buildShimmerContainer(
          width: widget.isTablet ? 160 : 130,
          height: widget.isTablet ? 20 : 18,
          borderRadius: BorderRadius.circular(4),
        ),

        SizedBox(height: widget.isTablet ? 8 : 6),

        // Category Tag - Match exact size and style
        _buildShimmerContainer(
          width: widget.isTablet ? 85 : 70,
          height: widget.isTablet ? 28 : 24,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildItemDescriptionSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerContainer(
          width: double.infinity,
          height: widget.isTablet ? 16 : 14,
          borderRadius: BorderRadius.circular(3),
        ),
        SizedBox(height: widget.isTablet ? 4 : 3),
        _buildShimmerContainer(
          width: widget.isTablet ? 200 : 160,
          height: widget.isTablet ? 16 : 14,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildItemStatsSkeleton() {
    return Row(
      children: [
        // Quantity Stat - Match exact style
        _buildShimmerContainer(
          width: widget.isTablet ? 75 : 65,
          height: widget.isTablet ? 32 : 28,
          borderRadius: BorderRadius.circular(6),
        ),

        SizedBox(width: widget.isTablet ? 12 : 8),

        // Claim Requests Stat - Match exact style
        _buildShimmerContainer(
          width: widget.isTablet ? 95 : 80,
          height: widget.isTablet ? 32 : 28,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildAddToCartButtonSkeleton() {
    return Container(
      margin: EdgeInsets.only(left: widget.isTablet ? 12 : 8),
      child: Column(
        children: [
          // Button
          _buildShimmerContainer(
            width: widget.isTablet ? 46 : 38,
            height: widget.isTablet ? 46 : 38,
            borderRadius: BorderRadius.circular(8),
          ),
          SizedBox(height: widget.isTablet ? 4 : 2),
          // Text
          _buildShimmerContainer(
            width: widget.isTablet ? 30 : 25,
            height: widget.isTablet ? 12 : 10,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

// Enhanced Skeleton List với staggered animation
class ItemWarehouseSkeletonList extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final int itemCount;

  const ItemWarehouseSkeletonList({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 100)),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(bottom: isTablet ? 8 : 6),
            child: ItemWarehouseSkeleton(
              isTablet: isTablet,
              colorScheme: colorScheme,
            ),
          ),
        ),
      ),
    );
  }
}

// Compact Skeleton cho Grid View (nếu cần)
class ItemWarehouseCompactSkeleton extends StatefulWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const ItemWarehouseCompactSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  State<ItemWarehouseCompactSkeleton> createState() => _ItemWarehouseCompactSkeletonState();
}

class _ItemWarehouseCompactSkeletonState extends State<ItemWarehouseCompactSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Màu base skeleton - đậm hơn
        final baseColor = widget.colorScheme.brightness == Brightness.dark 
            ? Colors.grey[800]! 
            : Colors.grey[300]!;
            
        final highlightColor = widget.colorScheme.brightness == Brightness.dark 
            ? Colors.grey[700]! 
            : Colors.grey[100]!;
            
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _animation.value, 0.0),
              end: Alignment(0.0 + _animation.value, 0.0),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.isTablet ? 16 : 12),
        side: BorderSide(
          color: widget.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            _buildShimmerContainer(
              width: double.infinity,
              height: widget.isTablet ? 120 : 100,
              borderRadius: BorderRadius.circular(8),
            ),
            SizedBox(height: widget.isTablet ? 12 : 8),
            
            // Title
            _buildShimmerContainer(
              width: double.infinity,
              height: widget.isTablet ? 18 : 16,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: widget.isTablet ? 6 : 4),
            
            // Category
            _buildShimmerContainer(
              width: widget.isTablet ? 80 : 60,
              height: widget.isTablet ? 24 : 20,
              borderRadius: BorderRadius.circular(6),
            ),
            SizedBox(height: widget.isTablet ? 8 : 6),
            
            // Stats Row
            Row(
              children: [
                _buildShimmerContainer(
                  width: widget.isTablet ? 60 : 50,
                  height: widget.isTablet ? 24 : 20,
                  borderRadius: BorderRadius.circular(6),
                ),
                const Spacer(),
                _buildShimmerContainer(
                  width: widget.isTablet ? 32 : 28,
                  height: widget.isTablet ? 32 : 28,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}