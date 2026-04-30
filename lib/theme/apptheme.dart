import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors based on the provided Design image
  static const Color neonGreen = Color(0xFF00E676);
  static const Color darkTeal = Color(0xFF1A2421);
  static const Color deepBlack = Color(0xFF0D0D0D);
  static const Color lightGrey = Color(0xFFF8F9F9);

  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF00C853); // A slightly more solid green for light mode
  static const Color lightBackground = lightGrey;
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Color(0xFF1A2421);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: darkTeal,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSurface: lightOnSurface,
        background: lightBackground,
        onBackground: lightOnSurface,
      ),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: lightOnSurface,
        displayColor: lightOnSurface,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: lightSurface,
        hourMinuteTextColor: lightPrimary,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: lightPrimary, width: 2),
        ),
        dayPeriodBorderSide: const BorderSide(color: lightPrimary, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        entryModeIconColor: lightPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
            color: lightOnSurface.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightPrimary, width: 1.5),
        ),
        iconColor: lightPrimary,
        prefixIconColor: lightPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Dark Theme Colors
  static const Color darkPrimary = neonGreen;
  static const Color darkBackground = deepBlack;
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Colors.white;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: Color(0xFF00BFA5),
        surface: darkSurface,
        onPrimary: deepBlack,
        onSurface: darkOnSurface,
        background: darkBackground,
        onBackground: darkOnSurface,
      ),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkOnSurface,
        displayColor: darkOnSurface,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: darkSurface,
        hourMinuteTextColor: darkPrimary,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: darkPrimary, width: 2),
        ),
        dayPeriodBorderSide: const BorderSide(color: darkPrimary, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        entryModeIconColor: darkPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: deepBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: deepBlack,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: TextStyle(
            color: darkOnSurface.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        iconColor: darkPrimary,
        prefixIconColor: darkPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
