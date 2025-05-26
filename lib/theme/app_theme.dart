import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'extensions/app_theme_extension.dart';

class AppTheme {
  static final lightExtension = const AppThemeExtension(
    primary: Color(0xFF3366FF), // Màu chủ đạo xanh dương
    onPrimary: Colors.white, // Text trên nền primary
    secondary: Color(0xFF5A6B8C), // Màu phụ đậm hơn accent
    onSecondary: Colors.white, // Text trên nền secondary
    background: Color(0xFFF1F5F9), // Nền sáng
    card: Color(0xFFFFFFFF), // Card trắng
    accentLight: Color(0xFFE0E7FF), // Accent xanh dương nhạt
    success: Color(0xFF22C55E), // Xanh lá cho trạng thái thành công
    danger: Color(0xFFEF4444), // Đỏ cho trạng thái lỗi
    warning: Color(0xFFF59E42), // Cam cho trạng thái cảnh báo
    primaryTextColor: Color(0xFF1A2238), // Text chính
    secondaryTextColor: Color(0xFF6B7280), // Text phụ
    surfaceContainer: Color(0xFFF8FAFC), // Nền container, nhạt hơn background

  );

  static final darkExtension = const AppThemeExtension(
    primary: Color(0xFF3366FF), // Chủ đạo giữ nguyên
    onPrimary: Color(0xFF1A2238),
    secondary: Color(0xFFB0B8C4), // Màu phụ nhạt hơn cho dark
    onSecondary: Colors.black,
    background: Color(0xFF181C20), // Nền tối
    card: Color(0xFF23272F), // Card tối
    accentLight: Color(0xFF25304B), // Accent xanh dương đậm cho dark
    success: Color(0xFF22C55E),
    danger: Color(0xFFEF4444),
    warning: Color(0xFFF59E42),
    primaryTextColor: Color(0xFFF1F5F9), // Text chính sáng
    secondaryTextColor: Color(0xFFB0B8C4), // Text phụ sáng
    surfaceContainer: Color(0xFF23272F), // Nền container tối
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: lightExtension.primary,
      secondary: lightExtension.accentLight,
      background: lightExtension.background,
      surface: lightExtension.card,
      onPrimary: lightExtension.onPrimary,
      onSecondary: lightExtension.onSecondary,
      onBackground: lightExtension.primaryTextColor,
      onSurface: lightExtension.primaryTextColor,
    ),
    scaffoldBackgroundColor: lightExtension.background,
    cardColor: lightExtension.card,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      bodyMedium: GoogleFonts.inter(color: lightExtension.primaryTextColor),
      bodySmall: GoogleFonts.inter(color: lightExtension.secondaryTextColor),
      titleLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: lightExtension.primaryTextColor),
    ),
    extensions: [lightExtension],
    appBarTheme: AppBarTheme(
      backgroundColor: lightExtension.background,
      foregroundColor: lightExtension.primaryTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: lightExtension.primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightExtension.primary,
        foregroundColor: lightExtension.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    cardTheme: CardTheme(
      color: lightExtension.card,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: lightExtension.accentLight, width: 1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightExtension.card,
      selectedItemColor: lightExtension.primary,
      unselectedItemColor: lightExtension.secondaryTextColor,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: darkExtension.primary,
      secondary: darkExtension.accentLight,
      background: darkExtension.background,
      surface: darkExtension.card,
      onPrimary: darkExtension.onPrimary,
      onSecondary: darkExtension.onSecondary,
      onBackground: darkExtension.primaryTextColor,
      onSurface: darkExtension.primaryTextColor,
    ),
    scaffoldBackgroundColor: darkExtension.background,
    cardColor: darkExtension.card,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyMedium: GoogleFonts.inter(color: darkExtension.primaryTextColor),
      bodySmall: GoogleFonts.inter(color: darkExtension.secondaryTextColor),
      titleLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: darkExtension.primaryTextColor),
    ),
    extensions: [darkExtension],
    appBarTheme: AppBarTheme(
      backgroundColor: darkExtension.background,
      foregroundColor: darkExtension.primaryTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: darkExtension.primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkExtension.primary,
        foregroundColor: darkExtension.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    cardTheme: CardTheme(
      color: darkExtension.card,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: darkExtension.accentLight, width: 1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkExtension.card,
      selectedItemColor: darkExtension.primary,
      unselectedItemColor: darkExtension.secondaryTextColor,
    ),
  );
}