import 'package:flutter/material.dart';

// Giữ nguyên ShimmerEffect
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

// Container skeleton đơn giản
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

// Skeleton đơn giản hóa cho AppointmentCard
class AppointmentSkeleton extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final bool showAction;
  final bool shimmerEnabled;
  final EdgeInsetsGeometry? margin;

  const AppointmentSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    this.showAction = true,
    this.shimmerEnabled = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Card(
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
              // Header đơn giản
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonContainer(
                    width: isTablet ? 100 : 80,
                    height: isTablet ? 24 : 20,
                    borderRadius: 8,
                    shimmer: shimmerEnabled,
                  ),
                  SkeletonContainer(
                    width: isTablet ? 60 : 50,
                    height: isTablet ? 14 : 12,
                    shimmer: shimmerEnabled,
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Content area đơn giản
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Time section - đơn giản hóa
                    Row(
                      children: [
                        SkeletonContainer(
                          width: isTablet ? 32 : 28,
                          height: isTablet ? 32 : 28,
                          borderRadius: 6,
                          shimmer: shimmerEnabled,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonContainer(
                                width: 60,
                                height: 12,
                                shimmer: shimmerEnabled,
                              ),
                              SizedBox(height: 8),
                              SkeletonContainer(
                                height: 16,
                                shimmer: shimmerEnabled,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: colorScheme.outline.withOpacity(0.1),
                    ),
                    SizedBox(height: 12),

                    // Items section - đơn giản hóa
                    Row(
                      children: [
                        SkeletonContainer(
                          width: isTablet ? 32 : 28,
                          height: isTablet ? 32 : 28,
                          borderRadius: 6,
                          shimmer: shimmerEnabled,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonContainer(
                                width: 80,
                                height: 12,
                                shimmer: shimmerEnabled,
                              ),
                              SizedBox(height: 8),
                              // Chỉ hiển thị 2 item thay vì 3
                              ...List.generate(
                                2,
                                (index) => Padding(
                                  padding: EdgeInsets.only(bottom: 6),
                                  child: SkeletonContainer(
                                    height: 14,
                                    shimmer: shimmerEnabled,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action button
              if (showAction) ...[
                SizedBox(height: isTablet ? 16 : 12),
                SkeletonContainer(
                  width: double.infinity,
                  height: isTablet ? 44 : 40,
                  borderRadius: 8,
                  shimmer: shimmerEnabled,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// List skeleton
class AppointmentSkeletonList extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final int itemCount;
  final bool shimmerEnabled;
  final EdgeInsetsGeometry? padding;

  const AppointmentSkeletonList({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    this.itemCount = 3, // Giảm từ 5 xuống 3
    this.shimmerEnabled = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => AppointmentSkeleton(
            isTablet: isTablet,
            colorScheme: colorScheme,
            showAction: index == 0, // Chỉ item đầu tiên có action
            shimmerEnabled: shimmerEnabled,
            margin: EdgeInsets.only(
              bottom: index < itemCount - 1 ? (isTablet ? 12 : 8) : 0,
            ),
          ),
        ),
      ),
    );
  }
}
