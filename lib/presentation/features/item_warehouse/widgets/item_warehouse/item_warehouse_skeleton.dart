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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
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
    double? opacity,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceVariant.withOpacity(
          (opacity ?? _animation.value) * 0.7,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
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
                // Item Image Skeleton
                _buildImageSkeleton(),
                SizedBox(width: widget.isTablet ? 16 : 12),

                // Item Info Skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSkeleton(),
                      SizedBox(height: widget.isTablet ? 8 : 6),
                      _buildDescriptionSkeleton(),
                      SizedBox(height: widget.isTablet ? 12 : 8),
                      _buildStatsSkeleton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSkeleton() {
    final imageSize = widget.isTablet ? 80.0 : 64.0;

    return _buildShimmerContainer(
      width: imageSize,
      height: imageSize,
      borderRadius: BorderRadius.circular(12),
      opacity: _animation.value * 0.6,
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Name - 2 lines
        _buildShimmerContainer(
          width: double.infinity,
          height: widget.isTablet ? 18 : 16,
        ),
        SizedBox(height: widget.isTablet ? 4 : 3),
        _buildShimmerContainer(
          width: widget.isTablet ? 150 : 120,
          height: widget.isTablet ? 18 : 16,
        ),

        SizedBox(height: widget.isTablet ? 6 : 4),

        // Category
        _buildShimmerContainer(
          width: widget.isTablet ? 80 : 70,
          height: widget.isTablet ? 24 : 20,
          borderRadius: BorderRadius.circular(6),
          opacity: _animation.value * 0.8,
        ),
      ],
    );
  }

  Widget _buildDescriptionSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerContainer(
          width: double.infinity,
          height: widget.isTablet ? 14 : 12,
          opacity: _animation.value * 0.7,
        ),
        SizedBox(height: widget.isTablet ? 4 : 3),
        _buildShimmerContainer(
          width: widget.isTablet ? 180 : 150,
          height: widget.isTablet ? 14 : 12,
          opacity: _animation.value * 0.7,
        ),
      ],
    );
  }

  Widget _buildStatsSkeleton() {
    return Row(
      children: [
        // Quantity stat
        _buildShimmerContainer(
          width: widget.isTablet ? 70 : 60,
          height: widget.isTablet ? 24 : 20,
          borderRadius: BorderRadius.circular(6),
          opacity: _animation.value * 0.8,
        ),

        SizedBox(width: widget.isTablet ? 12 : 8),

        // Claim requests stat
        _buildShimmerContainer(
          width: widget.isTablet ? 90 : 75,
          height: widget.isTablet ? 24 : 20,
          borderRadius: BorderRadius.circular(6),
          opacity: _animation.value * 0.8,
        ),
      ],
    );
  }
}

// Skeleton list để hiển thị nhiều skeleton cùng lúc
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
          (index) => Padding(
            padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
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
