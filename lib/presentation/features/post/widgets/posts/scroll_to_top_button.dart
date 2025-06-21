import 'package:flutter/material.dart';

class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final bool isTablet;
  final ColorScheme colorScheme;

  const ScrollToTopButton({
    super.key,
    required this.scrollController,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (widget.scrollController.offset > 300 && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
      _animationController.forward();
    } else if (widget.scrollController.offset <= 300 && _isVisible) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      right: widget.isTablet ? 24 : 16,
      bottom: widget.isTablet ? 140 : 120, // Để tránh đè lên FAB
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.isTablet ? 56 : 48,
                height: widget.isTablet ? 56 : 48,
                decoration: BoxDecoration(
                  color: widget.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.colorScheme.shadow.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: widget.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _scrollToTop,
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: widget.isTablet ? 28 : 24,
                        color: widget.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
