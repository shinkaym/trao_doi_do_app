import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color surfaceContainer;
  final Color danger;

  const AppThemeExtension({
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.surfaceContainer,
    required this.danger,
  });

  @override
  AppThemeExtension copyWith({
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? surfaceContainer,
    Color? danger,
  }) {
    return AppThemeExtension(
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      primaryTextColor:
          Color.lerp(primaryTextColor, other.primaryTextColor, t)!,
      secondaryTextColor:
          Color.lerp(secondaryTextColor, other.secondaryTextColor, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
