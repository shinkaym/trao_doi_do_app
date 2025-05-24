import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'extensions/app_theme_extension.dart';

class AppTheme {
  static final lightExtension = const AppThemeExtension(
    primary: Color(0xFF3366FF), // Blue, giữ nguyên
    onPrimary: Colors.white, // Giữ nguyên
    secondary: Color(0xFFFFCA28), // Giữ nguyên
    onSecondary: Colors.black, // Giữ nguyên
    background: Colors.white, // Giữ nguyên
    card: Color(0xFFF8F9FD), // Giữ nguyên
    accentLight: Color(0xFFE0E7FF), // Giữ nguyên
    success: Color(0xFF00C851), // Giữ nguyên
    danger: Color(0xFFFF4444), // Giữ nguyên
    warning: Color(0xFFFF8800), // Giữ nguyên
    primaryTextColor: Color(0xFF1A2238), // Giữ nguyên
    secondaryTextColor: Color(0xFF6B7280), // Giữ nguyên
    surfaceContainer: Color(0xFFF1F5F9), // Nhạt hơn (xám rất nhạt)
  );

  static final darkExtension = const AppThemeExtension(
    primary: Color(0xFF3366FF), // Giữ nguyên
    onPrimary: Colors.white, // Giữ nguyên
    secondary: Color(0xFFFFCA28), // Giữ nguyên
    onSecondary: Colors.black, // Giữ nguyên
    background: Color(0xFF121212), // Giữ nguyên
    card: Color(0xFF1E1E1E), // Giữ nguyên
    accentLight: Color(0xFF374151), // Giữ nguyên
    success: Color(0xFF00C851), // Giữ nguyên
    danger: Color(0xFFFF4444), // Giữ nguyên
    warning: Color(0xFFFF8800), // Giữ nguyên
    primaryTextColor: Colors.white, // Giữ nguyên
    secondaryTextColor: Color(0xFFB0B8C4), // Giữ nguyên
    surfaceContainer: Color(0xFF3A3A3A), // Nhạt hơn (xám sáng hơn)
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Color(0xFF3366FF),
    scaffoldBackgroundColor: lightExtension.background,
    cardColor: lightExtension.card,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      bodyMedium: GoogleFonts.inter(color: lightExtension.primaryTextColor),
      bodySmall: GoogleFonts.inter(color: lightExtension.secondaryTextColor),
    ),
    extensions: [lightExtension],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Color(0xFF3366FF),
    scaffoldBackgroundColor: darkExtension.background,
    cardColor: darkExtension.card,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyMedium: GoogleFonts.inter(color: darkExtension.primaryTextColor),
      bodySmall: GoogleFonts.inter(color: darkExtension.secondaryTextColor),
    ),
    extensions: [darkExtension],
  );
}