import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/app_theme.dart'; // Đường dẫn phù hợp với dự án bạn
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  AppThemeExtension get appColors {
    final ext = theme.extension<AppThemeExtension>();
    return ext ??
        (isDarkMode ? AppTheme.darkExtension : AppTheme.lightExtension);
  }
}
