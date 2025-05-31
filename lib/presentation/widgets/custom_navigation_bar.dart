import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trao_doi_do_app/core/constants/nav_bar_constants.dart';

class CustomBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showLabels;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.showLabels = true,
  }) : super(key: key);

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != widget.currentIndex) {
      HapticFeedback.lightImpact();
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: isTablet ? 80 : 70,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 12,
            vertical: isTablet ? 12 : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: NavBarConstants.navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildNavItem(context, item, index, isTablet);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavigationItemConfig item,
    int index,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = widget.currentIndex == index;

    if (item.isSpecial) {
      return _buildSpecialButton(context, item, index, isTablet);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _scaleAnimation.value : 1.0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 8 : 6,
                  horizontal: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isTablet ? 4 : 2),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? colorScheme.primary.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.inactiveIcon,
                        size: isTablet ? 26 : 22,
                        color: isSelected 
                            ? colorScheme.primary
                            : theme.hintColor.withOpacity(0.7),
                      ),
                    ),
                    if (widget.showLabels) ...[
                      SizedBox(height: isTablet ? 4 : 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected 
                              ? colorScheme.primary
                              : theme.hintColor.withOpacity(0.8),
                        ),
                        child: Text(
                          item.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpecialButton(
    BuildContext context,
    NavigationItemConfig item,
    int index,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = widget.currentIndex == index;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isTablet ? 60 : 50,
          height: isTablet ? 60 : 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected 
                  ? [colorScheme.primary, colorScheme.primary.withOpacity(0.8)]
                  : [colorScheme.primaryContainer, colorScheme.primaryContainer.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? colorScheme.primary : colorScheme.primaryContainer)
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.inactiveIcon,
                size: isTablet ? 28 : 24,
                color: isSelected ? Colors.white : colorScheme.onPrimaryContainer,
              ),
              if (widget.showLabels) ...[
                SizedBox(height: isTablet ? 2 : 1),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 8,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}