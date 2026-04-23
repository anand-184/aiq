import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette Colors
  static const Color color1 = Color(0xFF346739);
  static const Color color2 = Color(0xFF79AE6F);
  static const Color color3 = Color(0xFF9FCB98);
  static const Color color4 = Color(0xFFF2EDC2);

  // Light Theme Colors
  static const Color lightPrimary = color1;
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white; // Using white for cleaner surface in light mode
  static const Color lightSecondary = color2;
  static const Color lightTextPrimary = color1;
  static const Color lightTextSecondary = color2;

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: lightBackground,
      primaryColor: lightPrimary,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSurface: lightTextPrimary,
        background: lightBackground,
        onBackground: lightTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: lightTextPrimary,
        displayColor: lightTextPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        iconSize: 30,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      iconTheme: IconThemeData(color:lightSurface),


      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
            color: lightTextSecondary.withOpacity(0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: lightPrimary, width: 1),
        ),
        iconColor: lightPrimary,
        prefixIconColor: lightPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightPrimary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // Dark Theme Colors
  static const Color darkPrimary = color3;
  static const Color darkBackground = color1;
  static const Color darkSurface = Color(0xFF2C5730); // Slightly lighter than background
  static const Color darkSecondary = color2;
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = color3;

  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkPrimary,
      useMaterial3: true,

      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        onPrimary: color1,
        onSurface: darkTextPrimary,
        background: darkBackground,
        onBackground: darkTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: color1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: color1,
        elevation: 0,
        iconSize: 30,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      iconTheme: const IconThemeData(color: darkPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: TextStyle(
            color: darkTextSecondary.withOpacity(0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: darkPrimary, width: 1),
        ),
        iconColor: darkPrimary,
        prefixIconColor: darkPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkPrimary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
