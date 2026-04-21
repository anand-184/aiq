import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF065F46);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
 static const Color lightTextPrimary = Color(0xFF10B981);
 static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightAlert = Color(0xFFF59E0B);
  static const Color lightDivider = Color(0xFFE5E7EB);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: lightBackground,
      primaryColor: lightPrimary,
      useMaterial3: true,
      colorScheme:const ColorScheme.light(
        primary: lightPrimary,
        onPrimary: Colors.white,
        surface: lightSurface,
        onSurface: lightTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      elevatedButtonTheme:ElevatedButtonThemeData(
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
        foregroundColor: lightTextPrimary,
        elevation: 0,
        iconSize: 30,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      iconTheme: const IconThemeData(color: lightPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: TextStyle(color: lightTextSecondary.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
        border:OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        iconColor: lightPrimary,
        prefixIconColor: lightPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightPrimary,
        elevation: 0,
        )

      );

  }



// Dark Theme Colors
  static const Color darkPrimary = Color(0xFF065F46);
 static const Color darkBackground = Color(0xFF065F46);
  static const Color darkSurface = Color(0xFF065F46);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
 static const Color darkTextSecondary = Color(0xFF9CA3AF);
 static const Color darkSuccess = Color(0xFF10B981);
 static const Color darkAlert = Color(0xFFFBBF24);
 static const Color darkDivider = Color(0xFF334155);

 static ThemeData get darkTheme {
   return ThemeData(
     scaffoldBackgroundColor: darkBackground,
     primaryColor: darkPrimary,
     useMaterial3: true,
     colorScheme:const ColorScheme.dark(
       primary: darkPrimary,
       onPrimary: darkTextPrimary,
       surface: darkSurface,
       onSurface: darkTextPrimary,
     ),
     textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
       bodyColor: darkTextPrimary,
       displayColor: darkTextPrimary,
     ),
     elevatedButtonTheme:ElevatedButtonThemeData(
       style: ElevatedButton.styleFrom(
         backgroundColor: darkPrimary,
         foregroundColor: darkTextPrimary,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(30),
         ),
         elevation: 0,
       ),
     ),
     floatingActionButtonTheme: FloatingActionButtonThemeData(
       backgroundColor: darkPrimary,
       foregroundColor: darkTextPrimary,
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
       hintStyle: TextStyle(color: darkTextSecondary.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
       border:OutlineInputBorder(
         borderRadius: BorderRadius.circular(15),
         borderSide: BorderSide.none,
       ),
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(15),
         borderSide: BorderSide.none,
       ),
       focusedBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(15),
         borderSide: BorderSide.none,
       )
     ),
     appBarTheme: const AppBarTheme(
       backgroundColor: darkBackground,
       foregroundColor: darkPrimary,
       elevation: 0,
       ),






   );
 }

}