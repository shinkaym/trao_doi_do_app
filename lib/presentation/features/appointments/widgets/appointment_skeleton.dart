import 'package:flutter/material.dart';

class AppointmentSkeleton extends StatefulWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool showAction;

  const AppointmentSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    this.showAction = true,
  });

  @override
  State<AppointmentSkeleton> createState() => _AppointmentSkeletonState();
}

class _AppointmentSkeletonState extends State<AppointmentSkeleton>
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
                // Header Row - Status Badge and ID
                _buildHeaderSection(),
                SizedBox(height: widget.isTablet ? 12 : 8),

                // User Section
                _buildUserSection(),
                SizedBox(height: widget.isTablet ? 16 : 12),

                // Time Section
                _buildTimeSection(),
                SizedBox(height: widget.isTablet ? 16 : 12),

                // Items Section
                _buildItemsSection(),

                // Action Section (conditionally shown)
                if (widget.showAction) _buildActionSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShimmerContainer(
          width: widget.isTablet ? 90 : 80,
          height: widget.isTablet ? 28 : 24,
          borderRadius: BorderRadius.circular(8),
          opacity: _animation.value * 0.8,
        ),
        _buildShimmerContainer(
          width: widget.isTablet ? 60 : 50,
          height: widget.isTablet ? 12 : 10,
          opacity: _animation.value * 0.6,
        ),
      ],
    );
  }

  Widget _buildUserSection() {
    return Row(
      children: [
        // Avatar
        _buildShimmerContainer(
          width: widget.isTablet ? 32 : 28,
          height: widget.isTablet ? 32 : 28,
          borderRadius: BorderRadius.circular(widget.isTablet ? 16 : 14),
        ),
        SizedBox(width: widget.isTablet ? 12 : 10),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User name
              _buildShimmerContainer(
                width: widget.isTablet ? 140 : 120,
                height: widget.isTablet ? 15 : 13,
              ),
              SizedBox(height: 2),
              // Created time
              _buildShimmerContainer(
                width: widget.isTablet ? 100 : 90,
                height: widget.isTablet ? 12 : 10,
                opacity: _animation.value * 0.6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Time icon placeholder
          _buildShimmerContainer(
            width: widget.isTablet ? 20 : 18,
            height: widget.isTablet ? 20 : 18,
            borderRadius: BorderRadius.circular(4),
            opacity: _animation.value * 0.6,
          ),
          SizedBox(width: widget.isTablet ? 12 : 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time label
                _buildShimmerContainer(
                  width: widget.isTablet ? 80 : 70,
                  height: widget.isTablet ? 12 : 10,
                  opacity: _animation.value * 0.6,
                ),
                SizedBox(height: 2),
                // Time range
                _buildShimmerContainer(
                  width: widget.isTablet ? 160 : 140,
                  height: widget.isTablet ? 15 : 13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Items header
        Row(
          children: [
            _buildShimmerContainer(
              width: widget.isTablet ? 16 : 14,
              height: widget.isTablet ? 16 : 14,
              borderRadius: BorderRadius.circular(4),
              opacity: _animation.value * 0.6,
            ),
            SizedBox(width: widget.isTablet ? 6 : 4),
            _buildShimmerContainer(
              width: widget.isTablet ? 120 : 100,
              height: widget.isTablet ? 14 : 12,
            ),
          ],
        ),
        SizedBox(height: widget.isTablet ? 12 : 8),

        // Item rows
        ...List.generate(3, (index) => _buildItemRowSkeleton()),

        // More items text
        Padding(
          padding: EdgeInsets.only(top: widget.isTablet ? 8 : 6),
          child: _buildShimmerContainer(
            width: widget.isTablet ? 100 : 80,
            height: widget.isTablet ? 12 : 10,
            opacity: _animation.value * 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRowSkeleton() {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.isTablet ? 6 : 4),
      child: Row(
        children: [
          // Bullet point
          _buildShimmerContainer(
            width: widget.isTablet ? 6 : 4,
            height: widget.isTablet ? 6 : 4,
            borderRadius: BorderRadius.circular(widget.isTablet ? 3 : 2),
          ),
          SizedBox(width: widget.isTablet ? 8 : 6),

          // Item name
          Expanded(
            child: _buildShimmerContainer(
              width: double.infinity,
              height: widget.isTablet ? 13 : 11,
              opacity: _animation.value * 0.7,
            ),
          ),

          // Quantity badge (sometimes shown)
          if ((DateTime.now().millisecond % 3) == 0) ...[
            SizedBox(width: widget.isTablet ? 8 : 6),
            _buildShimmerContainer(
              width: widget.isTablet ? 24 : 20,
              height: widget.isTablet ? 16 : 14,
              borderRadius: BorderRadius.circular(4),
              opacity: _animation.value * 0.8,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        SizedBox(height: widget.isTablet ? 16 : 12),
        _buildShimmerContainer(
          width: double.infinity,
          height: widget.isTablet ? 44 : 40,
          borderRadius: BorderRadius.circular(8),
          opacity: _animation.value * 0.8,
        ),
      ],
    );
  }
}

// Skeleton list để hiển thị nhiều skeleton cùng lúc
class AppointmentSkeletonList extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final int itemCount;

  const AppointmentSkeletonList({
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
            child: AppointmentSkeleton(
              isTablet: isTablet,
              colorScheme: colorScheme,
              showAction: index % 2 == 0, // Show action randomly
            ),
          ),
        ),
      ),
    );
  }
}
