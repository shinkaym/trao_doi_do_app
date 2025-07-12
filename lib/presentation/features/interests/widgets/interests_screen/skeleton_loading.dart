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
    this.period = const Duration(milliseconds: 1500),
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
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
        (brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[100]!);

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
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

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

// ===== FIXED VERSION =====
class SkeletonLoading extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const SkeletonLoading({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    // Thay đổi: Sử dụng Column thay vì CustomScrollView
    return Column(
      children: [
        // Tạo danh sách skeleton items
        ...List.generate(3, (index) {
          return Column(
            children: [
              InterestPostSkeleton(
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
                showAuthor: index == 0,
                showMessage: index < 2,
              ),
              if (index < 2) // Thêm spacing giữa các items
                SizedBox(height: isTablet ? 8 : 6),
            ],
          );
        }),
      ],
    );
  }
}

// Alternative: Nếu bạn muốn giữ CustomScrollView
class SkeletonLoadingScrollable extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const SkeletonLoadingScrollable({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6, // Đặt chiều cao cố định
      child: CustomScrollView(
        physics:
            const NeverScrollableScrollPhysics(), // Tắt scroll để tránh xung đột
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),
          SliverList.separated(
            separatorBuilder:
                (context, index) => SizedBox(height: isTablet ? 8 : 6),
            itemCount: 3,
            itemBuilder: (context, index) {
              return InterestPostSkeleton(
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
                showAuthor: index == 0,
                showMessage: index < 2,
              );
            },
          ),
        ],
      ),
    );
  }
}

class InterestPostSkeleton extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool showAuthor;
  final bool showMessage;

  const InterestPostSkeleton({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    this.showAuthor = true,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Post type và time
            Row(
              children: [
                SkeletonContainer(
                  width: isTablet ? 100 : 80,
                  height: isTablet ? 28 : 24,
                  borderRadius: 8,
                ),
                const Spacer(),
                SkeletonContainer(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 16 : 14,
                  borderRadius: 6,
                ),
              ],
            ),

            // Author section
            if (showAuthor) ...[
              SizedBox(height: isTablet ? 12 : 8),
              Row(
                children: [
                  SkeletonContainer(
                    width: isTablet ? 32 : 28,
                    height: isTablet ? 32 : 28,
                    borderRadius: 16,
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonContainer(
                          width: isTablet ? 120 : 100,
                          height: isTablet ? 15 : 13,
                          borderRadius: 4,
                        ),
                        SizedBox(height: 4),
                        SkeletonContainer(
                          width: isTablet ? 80 : 70,
                          height: isTablet ? 12 : 10,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: isTablet ? 16 : 12),

            // Post content area
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonContainer(
                    width: double.infinity,
                    height: isTablet ? 18 : 16,
                    borderRadius: 4,
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
                  SkeletonContainer(
                    width: double.infinity * 0.9,
                    height: isTablet ? 15 : 13,
                    borderRadius: 4,
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  SkeletonContainer(
                    width: double.infinity * 0.7,
                    height: isTablet ? 15 : 13,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),

            // Latest message section
            if (showMessage) ...[
              SizedBox(height: isTablet ? 12 : 8),
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    SkeletonContainer(
                      width: isTablet ? 16 : 14,
                      height: isTablet ? 16 : 14,
                      borderRadius: 3,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonContainer(
                            width: double.infinity * 0.8,
                            height: isTablet ? 14 : 12,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 4),
                          SkeletonContainer(
                            width: double.infinity * 0.6,
                            height: isTablet ? 14 : 12,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    SkeletonContainer(
                      width: isTablet ? 22 : 18,
                      height: isTablet ? 22 : 18,
                      borderRadius: 11,
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: isTablet ? 16 : 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SkeletonContainer(
                  width: isTablet ? 44 : 38,
                  height: isTablet ? 44 : 38,
                  borderRadius: 8,
                ),
                SizedBox(width: isTablet ? 8 : 6),
                SkeletonContainer(
                  width: isTablet ? 44 : 38,
                  height: isTablet ? 44 : 38,
                  borderRadius: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
