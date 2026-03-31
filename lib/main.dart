import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Extracted color palette
    const royalBlue = Color(0xFF334EAC);
    const moonWhite = Color(0xFFF7F2EB);
    const chinaBlue = Color(0xFF7096D1);
    const asianPear = Color(0xFFF2F0DE);
    const midnightBlue = Color(0xFF081F5C);
    const dawnBlue = Color(0xFFD0E3FF);
    const jicamaWhite = Color(0xFFFFF9F0);
    const porcelainGray = Color(0xFFEDF1F6);
    const skyBlue = Color(0xFFBAD6EB);

    return MaterialApp(
      title: 'Material Theme App',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: moonWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: royalBlue,
          brightness: Brightness.light,
          primary: royalBlue,
          onPrimary: jicamaWhite,
          primaryContainer: dawnBlue,
          onPrimaryContainer: midnightBlue,
          secondary: chinaBlue,
          onSecondary: jicamaWhite,
          secondaryContainer: skyBlue,
          onSecondaryContainer: midnightBlue,
          tertiary: asianPear,
          onTertiary: midnightBlue,
          surface: moonWhite,
          onSurface: midnightBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: dawnBlue,
          foregroundColor: midnightBlue,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: royalBlue,
          foregroundColor: jicamaWhite,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: midnightBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: royalBlue,
          brightness: Brightness.dark,
          primary: chinaBlue,
          onPrimary: midnightBlue,
          primaryContainer: royalBlue,
          onPrimaryContainer: dawnBlue,
          secondary: skyBlue,
          onSecondary: midnightBlue,
          secondaryContainer: chinaBlue,
          onSecondaryContainer: jicamaWhite,
          tertiary: porcelainGray,
          onTertiary: midnightBlue,
          surface: midnightBlue,
          onSurface: porcelainGray,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: royalBlue,
          foregroundColor: dawnBlue,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: chinaBlue,
          foregroundColor: midnightBlue,
        ),
      ),
      home: const MyHomePage(title: 'App Theme Showcase'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Welcome to the App',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
