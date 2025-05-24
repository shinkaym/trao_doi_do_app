import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'extensions/app_theme_extension.dart';

class AppTheme {
  static final lightExtension = const AppThemeExtension(
    primaryTextColor: Color(0xFF222222),
    secondaryTextColor: Color(0xFF666666),
    surfaceContainer: Color(0xFFF2F2F2),
    danger: Colors.redAccent,
  );

  static final darkExtension = const AppThemeExtension(
    primaryTextColor: Colors.white,
    secondaryTextColor: Colors.white70,
    surfaceContainer: Color(0xFF121212),
    danger: Colors.redAccent,
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.teal,
    textTheme: GoogleFonts.interTextTheme(),
    extensions: [lightExtension],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.teal,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    extensions: [darkExtension],
  );
}
