import 'package:flutter/material.dart';

class PostSkeleton extends StatefulWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool showImage;
  final bool showAuthor;
  final bool showReward;

  const PostSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    this.showImage = true,
    this.showAuthor = true,
    this.showReward = true,
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
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBaseColor() {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey[300]!
        : Colors.grey[700]!;
  }

  Color _getHighlightColor() {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey[100]!
        : Colors.grey[600]!;
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [_getBaseColor(), _getHighlightColor(), _getBaseColor()],
              stops: [0.0, _animation.value, 1.0],
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
        side: BorderSide(color: widget.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Type badge only
            _buildShimmerContainer(
              width: widget.isTablet ? 80 : 70,
              height: widget.isTablet ? 24 : 20,
              borderRadius: BorderRadius.circular(6),
            ),

            SizedBox(height: widget.isTablet ? 16 : 12),

            // Author Section (simplified)
            if (widget.showAuthor) ...[
              Row(
                children: [
                  _buildShimmerContainer(
                    width: widget.isTablet ? 28 : 24,
                    height: widget.isTablet ? 28 : 24,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  SizedBox(width: widget.isTablet ? 10 : 8),
                  _buildShimmerContainer(
                    width: widget.isTablet ? 120 : 100,
                    height: widget.isTablet ? 14 : 12,
                  ),
                ],
              ),
              SizedBox(height: widget.isTablet ? 16 : 12),
            ],

            // Title - 2 lines only
            _buildShimmerContainer(
              width: double.infinity,
              height: widget.isTablet ? 18 : 16,
            ),
            SizedBox(height: widget.isTablet ? 8 : 6),
            _buildShimmerContainer(
              width: MediaQuery.of(context).size.width * 0.6,
              height: widget.isTablet ? 18 : 16,
            ),

            SizedBox(height: widget.isTablet ? 12 : 10),

            // Description - 2 lines only
            _buildShimmerContainer(
              width: double.infinity,
              height: widget.isTablet ? 14 : 12,
            ),
            SizedBox(height: widget.isTablet ? 6 : 4),
            _buildShimmerContainer(
              width: MediaQuery.of(context).size.width * 0.8,
              height: widget.isTablet ? 14 : 12,
            ),

            // Images Section (simplified)
            if (widget.showImage) ...[
              SizedBox(height: widget.isTablet ? 16 : 12),
              Row(
                children: [
                  _buildShimmerContainer(
                    width: widget.isTablet ? 60 : 50,
                    height: widget.isTablet ? 60 : 50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  SizedBox(width: widget.isTablet ? 8 : 6),
                  _buildShimmerContainer(
                    width: widget.isTablet ? 60 : 50,
                    height: widget.isTablet ? 60 : 50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ],

            SizedBox(height: widget.isTablet ? 16 : 12),

            // Bottom row - Location and reward
            Row(
              children: [
                _buildShimmerContainer(
                  width: widget.isTablet ? 100 : 80,
                  height: widget.isTablet ? 12 : 10,
                ),
                const Spacer(),
                if (widget.showReward)
                  _buildShimmerContainer(
                    width: widget.isTablet ? 60 : 50,
                    height: widget.isTablet ? 20 : 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Simplified skeleton list
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
            padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
            child: PostSkeleton(
              isTablet: isTablet,
              colorScheme: colorScheme,
              showImage: index % 2 == 0, // Show images every other item
              showAuthor: index % 3 != 0, // Hide author every 3rd item
              showReward: index % 4 == 0, // Show reward every 4th item
            ),
          ),
        ),
      ),
    );
  }
}
