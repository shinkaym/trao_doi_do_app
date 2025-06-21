import 'package:flutter/material.dart';

class PostSkeleton extends StatefulWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool showImage;

  const PostSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    this.showImage = true,
  });

  @override
  State<PostSkeleton> createState() => _PostSkeletonState();
}

class _PostSkeletonState extends State<PostSkeleton>
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - Type Badge
                _buildHeaderSection(),
                SizedBox(height: widget.isTablet ? 12 : 8),

                // Author Section
                _buildAuthorSection(),
                SizedBox(height: widget.isTablet ? 16 : 12),

                // Title and Description
                _buildTitleAndDescriptionSection(),

                // Images Section (conditionally shown)
                if (widget.showImage) _buildImagesSection(),
                SizedBox(height: widget.isTablet ? 16 : 12),

                // Location and Reward Section
                _buildLocationAndRewardSection(),

                // Stats Section
                _buildStatsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildShimmerContainer(
          width: widget.isTablet ? 80 : 70,
          height: widget.isTablet ? 28 : 24,
          borderRadius: BorderRadius.circular(8),
          opacity: _animation.value * 0.8,
        ),
      ],
    );
  }

  Widget _buildAuthorSection() {
    return Row(
      children: [
        // Avatar
        _buildShimmerContainer(
          width: widget.isTablet ? 32 : 28,
          height: widget.isTablet ? 32 : 28,
          borderRadius: BorderRadius.circular(widget.isTablet ? 16 : 14),
        ),
        SizedBox(width: widget.isTablet ? 12 : 10),

        // Author info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author name
              _buildShimmerContainer(
                width: widget.isTablet ? 120 : 100,
                height: widget.isTablet ? 15 : 13,
              ),
              SizedBox(height: 2),
              // Time
              _buildShimmerContainer(
                width: widget.isTablet ? 80 : 70,
                height: widget.isTablet ? 12 : 10,
                opacity: _animation.value * 0.6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title - 2 lines maximum
        _buildShimmerContainer(
          width: double.infinity,
          height: widget.isTablet ? 18 : 16,
        ),
        SizedBox(height: widget.isTablet ? 6 : 4),
        _buildShimmerContainer(
          width: widget.isTablet ? 240 : 200,
          height: widget.isTablet ? 18 : 16,
        ),
        
        SizedBox(height: widget.isTablet ? 12 : 8),

        // Description - 3 lines maximum
        _buildShimmerContainer(
          width: double.infinity,
          height: widget.isTablet ? 15 : 13,
          opacity: _animation.value * 0.7,
        ),
        SizedBox(height: widget.isTablet ? 6 : 4),
        _buildShimmerContainer(
          width: double.infinity,
          height: widget.isTablet ? 15 : 13,
          opacity: _animation.value * 0.7,
        ),
        SizedBox(height: widget.isTablet ? 6 : 4),
        _buildShimmerContainer(
          width: widget.isTablet ? 180 : 150,
          height: widget.isTablet ? 15 : 13,
          opacity: _animation.value * 0.7,
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      children: [
        SizedBox(height: widget.isTablet ? 16 : 12),
        SizedBox(
          height: widget.isTablet ? 80 : 60,
          child: Row(
            children: List.generate(
              3, // Show 3 image placeholders
              (index) => Container(
                margin: EdgeInsets.only(
                  right: index < 2 ? (widget.isTablet ? 12 : 8) : 0,
                ),
                child: _buildShimmerContainer(
                  width: widget.isTablet ? 80 : 60,
                  height: widget.isTablet ? 80 : 60,
                  borderRadius: BorderRadius.circular(8),
                  opacity: _animation.value * 0.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndRewardSection() {
    return Column(
      children: [
        Row(
          children: [
            // Location icon placeholder
            _buildShimmerContainer(
              width: widget.isTablet ? 16 : 14,
              height: widget.isTablet ? 16 : 14,
              borderRadius: BorderRadius.circular(4),
              opacity: _animation.value * 0.6,
            ),
            SizedBox(width: widget.isTablet ? 6 : 4),

            // Location text placeholder
            Expanded(
              child: _buildShimmerContainer(
                width: double.infinity,
                height: widget.isTablet ? 13 : 11,
                opacity: _animation.value * 0.6,
              ),
            ),

            SizedBox(width: widget.isTablet ? 12 : 8),

            // Reward placeholder (sometimes shown)
            if (widget.showImage) // Use showImage as a random condition
              _buildShimmerContainer(
                width: widget.isTablet ? 60 : 50,
                height: widget.isTablet ? 24 : 20,
                borderRadius: BorderRadius.circular(6),
                opacity: _animation.value * 0.8,
              ),
          ],
        ),
        SizedBox(height: widget.isTablet ? 12 : 8),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        // First stat (like interest count)
        _buildShimmerContainer(
          width: widget.isTablet ? 50 : 40,
          height: widget.isTablet ? 24 : 20,
          borderRadius: BorderRadius.circular(6),
          opacity: _animation.value * 0.8,
        ),
        SizedBox(width: widget.isTablet ? 16 : 12),

        // Second stat (like item count)
        _buildShimmerContainer(
          width: widget.isTablet ? 45 : 35,
          height: widget.isTablet ? 24 : 20,
          borderRadius: BorderRadius.circular(6),
          opacity: _animation.value * 0.8,
        ),
      ],
    );
  }
}

// Skeleton list để hiển thị nhiều skeleton cùng lúc
class PostSkeletonList extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final int itemCount;

  const PostSkeletonList({
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
            child: PostSkeleton(
              isTablet: isTablet,
              colorScheme: colorScheme,
              showImage: index % 3 == 0, // Show images randomly
            ),
          ),
        ),
      ),
    );
  }
}