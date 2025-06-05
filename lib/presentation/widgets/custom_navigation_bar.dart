import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/nav_bar_constants.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class CustomBottomNavigation extends HookConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showLabels;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng useAnimationController thay cho AnimationController
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    // Sử dụng useMemoized để tạo animation
    final scaleAnimation = useMemoized(
      () => Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
      [animationController],
    );

    // Function để xử lý tap
    void onItemTapped(int index) {
      if (index != currentIndex) {
        HapticFeedback.lightImpact();
        animationController.forward().then((_) {
          animationController.reverse();
        });
        onTap(index);
      }
    }

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

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
            children:
                NavBarConstants.navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildNavItem(
                    context,
                    item,
                    index,
                    isTablet,
                    scaleAnimation,
                    onItemTapped,
                  );
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
    Animation<double> scaleAnimation,
    Function(int) onItemTapped,
  ) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isSelected = currentIndex == index;

    if (item.isSpecial) {
      return _buildSpecialButton(context, item, index, isTablet, onItemTapped);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        child: AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? scaleAnimation.value : 1.0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 8 : 6,
                  horizontal: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
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
                        color:
                            isSelected
                                ? colorScheme.primary.withOpacity(0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.inactiveIcon,
                        size: isTablet ? 26 : 22,
                        color:
                            isSelected
                                ? colorScheme.primary
                                : theme.hintColor.withOpacity(0.7),
                      ),
                    ),
                    if (showLabels) ...[
                      SizedBox(height: isTablet ? 4 : 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
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
    Function(int) onItemTapped,
  ) {
    final colorScheme = context.colorScheme;
    final isSelected = currentIndex == index;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isTablet ? 60 : 50,
          height: isTablet ? 60 : 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isSelected
                      ? [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ]
                      : [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withOpacity(0.8),
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isSelected
                        ? colorScheme.primary
                        : colorScheme.primaryContainer)
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
                color:
                    isSelected ? Colors.white : colorScheme.onPrimaryContainer,
              ),
              if (showLabels) ...[
                SizedBox(height: isTablet ? 2 : 1),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 8,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected
                            ? Colors.white
                            : colorScheme.onPrimaryContainer,
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
