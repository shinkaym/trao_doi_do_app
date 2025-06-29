import 'package:flutter/material.dart';

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration period;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerEffect({
    Key? key,
    required this.child,
    this.enabled = true,
    this.period = const Duration(milliseconds: 2000), // Tăng thời gian để chậm hơn
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.period, vsync: this);
    // Giảm độ di chuyển của gradient
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut), // Curve mượt mà hơn
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final brightness = Theme.of(context).brightness;
    final baseColor =
        widget.baseColor ??
        (brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor =
        widget.highlightColor ??
        // Giảm độ tương phản của highlight color
        (brightness == Brightness.dark ? Colors.grey[750]! : Colors.grey[200]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                baseColor,
                highlightColor,
                baseColor,
                baseColor,
              ],
              // Tăng độ rộng của highlight area để mượt hơn
              stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Container skeleton với hiệu ứng nhẹ hơn
class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool shimmer;

  const SkeletonContainer({
    Key? key,
    this.width,
    this.height,
    this.borderRadius = 4,
    this.margin,
    this.shimmer = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color =
        brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!;

    final container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    return shimmer ? ShimmerEffect(child: container) : container;
  }
}

// Current User Section Skeleton - giảm một số shimmer elements
class CurrentUserSectionSkeleton extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool shimmerEnabled;

  const CurrentUserSectionSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    this.shimmerEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 32 : 24),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.3),
            colorScheme.primary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header - bỏ shimmer cho một số elements nhỏ
          Row(
            children: [
              SkeletonContainer(
                width: isTablet ? 28 : 24,
                height: isTablet ? 28 : 24,
                borderRadius: 14,
                shimmer: false, // Bỏ shimmer cho icon nhỏ
              ),
              SizedBox(width: isTablet ? 12 : 8),
              SkeletonContainer(
                width: isTablet ? 140 : 120,
                height: isTablet ? 18 : 16,
                borderRadius: 8,
                shimmer: shimmerEnabled,
              ),
              const Spacer(),
              SkeletonContainer(
                width: isTablet ? 80 : 70,
                height: isTablet ? 32 : 28,
                borderRadius: 12,
                shimmer: shimmerEnabled,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          // User info row
          Row(
            children: [
              // Avatar with rank badge
              Stack(
                children: [
                  SkeletonContainer(
                    width: isTablet ? 80 : 70,
                    height: isTablet ? 80 : 70,
                    borderRadius: 40,
                    shimmer: shimmerEnabled,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SkeletonContainer(
                      width: isTablet ? 28 : 24,
                      height: isTablet ? 18 : 16,
                      borderRadius: 12,
                      shimmer: false, // Bỏ shimmer cho badge nhỏ
                    ),
                  ),
                ],
              ),
              SizedBox(width: isTablet ? 20 : 16),
              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    SkeletonContainer(
                      width: isTablet ? 160 : 140,
                      height: isTablet ? 18 : 16,
                      borderRadius: 8,
                      shimmer: shimmerEnabled,
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    // Major
                    SkeletonContainer(
                      width: isTablet ? 120 : 100,
                      height: isTablet ? 14 : 12,
                      borderRadius: 6,
                      shimmer: shimmerEnabled,
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    // Stats row - giảm shimmer cho icons
                    Row(
                      children: [
                        // Points stat
                        Row(
                          children: [
                            SkeletonContainer(
                              width: isTablet ? 18 : 16,
                              height: isTablet ? 18 : 16,
                              borderRadius: 9,
                              shimmer: false, // Bỏ shimmer cho icon
                            ),
                            SizedBox(width: isTablet ? 6 : 4),
                            SkeletonContainer(
                              width: isTablet ? 50 : 40,
                              height: isTablet ? 14 : 12,
                              borderRadius: 6,
                              shimmer: shimmerEnabled,
                            ),
                          ],
                        ),
                        SizedBox(width: isTablet ? 20 : 16),
                        // Good deeds stat
                        Row(
                          children: [
                            SkeletonContainer(
                              width: isTablet ? 18 : 16,
                              height: isTablet ? 18 : 16,
                              borderRadius: 9,
                              shimmer: false, // Bỏ shimmer cho icon
                            ),
                            SizedBox(width: isTablet ? 6 : 4),
                            SkeletonContainer(
                              width: isTablet ? 60 : 50,
                              height: isTablet ? 14 : 12,
                              borderRadius: 6,
                              shimmer: shimmerEnabled,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Leaderboard Item Skeleton - tối ưu shimmer
class LeaderboardItemSkeleton extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool shimmerEnabled;
  final bool isTopFive;

  const LeaderboardItemSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    this.shimmerEnabled = true,
    this.isTopFive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color:
            isTopFive
                ? colorScheme.primaryContainer.withOpacity(0.1)
                : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isTopFive
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outline.withOpacity(0.2),
          width: isTopFive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge - chỉ shimmer cho top 3
          SkeletonContainer(
            width: isTablet ? 50 : 45,
            height: isTablet ? 50 : 45,
            borderRadius: 25,
            shimmer: isTopFive ? shimmerEnabled : false,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          // Avatar
          SkeletonContainer(
            width: isTablet ? 50 : 45,
            height: isTablet ? 50 : 45,
            borderRadius: 25,
            shimmer: shimmerEnabled,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                SkeletonContainer(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 16 : 14,
                  borderRadius: 8,
                  shimmer: shimmerEnabled,
                ),
                SizedBox(height: isTablet ? 6 : 4),
                // Major
                SkeletonContainer(
                  width: isTablet ? 80 : 70,
                  height: isTablet ? 12 : 10,
                  borderRadius: 6,
                  shimmer: shimmerEnabled,
                ),
                SizedBox(height: isTablet ? 6 : 4),
                // Good deeds count
                Row(
                  children: [
                    SkeletonContainer(
                      width: isTablet ? 14 : 12,
                      height: isTablet ? 14 : 12,
                      borderRadius: 7,
                      shimmer: false, // Bỏ shimmer cho icon nhỏ
                    ),
                    SizedBox(width: isTablet ? 4 : 3),
                    SkeletonContainer(
                      width: isTablet ? 70 : 60,
                      height: isTablet ? 13 : 11,
                      borderRadius: 6,
                      shimmer: shimmerEnabled,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Points container
          SkeletonContainer(
            width: isTablet ? 70 : 60,
            height: isTablet ? 32 : 28,
            borderRadius: 12,
            shimmer: shimmerEnabled,
          ),
        ],
      ),
    );
  }
}

// Ranking Screen Skeleton
class RankingScreenSkeleton extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool shimmerEnabled;
  final int leaderboardItemCount;

  const RankingScreenSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    this.shimmerEnabled = true,
    this.leaderboardItemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Current User Section
        CurrentUserSectionSkeleton(
          isTablet: isTablet,
          colorScheme: colorScheme,
          shimmerEnabled: shimmerEnabled,
        ),

        // Leaderboard Header
        Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 32 : 24,
            isTablet ? 24 : 20,
            isTablet ? 32 : 24,
            isTablet ? 16 : 12,
          ),
          child: Row(
            children: [
              SkeletonContainer(
                width: isTablet ? 28 : 24,
                height: isTablet ? 28 : 24,
                borderRadius: 14,
                shimmer: false, // Bỏ shimmer cho icon header
              ),
              SizedBox(width: isTablet ? 12 : 8),
              SkeletonContainer(
                width: isTablet ? 140 : 120,
                height: isTablet ? 20 : 18,
                borderRadius: 8,
                shimmer: shimmerEnabled,
              ),
            ],
          ),
        ),

        // Leaderboard Items
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
          child: Column(
            children: List.generate(
              leaderboardItemCount,
              (index) => LeaderboardItemSkeleton(
                isTablet: isTablet,
                colorScheme: colorScheme,
                shimmerEnabled: shimmerEnabled,
                isTopFive: index < 3, // Top 3 có styling đặc biệt
              ),
            ),
          ),
        ),

        // Bottom padding
        SizedBox(height: isTablet ? 32 : 24),
      ],
    );
  }
}