import 'package:flutter/material.dart';

extension MediaQueryExtensions on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isTablet => screenWidth > 600;
  bool get isMobile => screenWidth <= 600;
  bool get isLargeScreen => screenWidth > 1024;

  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get statusBarHeight => viewPadding.top;
  double get bottomPadding => viewPadding.bottom;

  EdgeInsets get responsiveHorizontalPadding =>
      EdgeInsets.symmetric(horizontal: isTablet ? 20.0 : 16.0);
  EdgeInsets get responsiveAllPadding => EdgeInsets.all(isTablet ? 20.0 : 16.0);
}
