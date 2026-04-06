import 'package:aiq/screens/adminScreens/adminHomeScreen.dart';
import 'package:aiq/screens/login_screen.dart';
import 'package:aiq/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const baseWhite = Color(0xFFFFFDF5);
    const darkBlue = Color(0xFF002140);

    return MaterialApp(
      title: 'Material Theme App',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: baseWhite,
        colorScheme: const ColorScheme.light(
          primary: darkBlue, // Container color
          onPrimary: baseWhite, // Text on container
          surface: baseWhite, // Background
          onSurface: darkBlue, // Just text
          primaryContainer: darkBlue,
          onPrimaryContainer: baseWhite,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: darkBlue),
          bodyMedium: TextStyle(color: darkBlue),
          titleLarge: TextStyle(color: darkBlue),
          headlineLarge: TextStyle(color: darkBlue),
          headlineMedium: TextStyle(color: darkBlue),
          headlineSmall: TextStyle(color: darkBlue),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlue,
            foregroundColor: baseWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkBlue.withOpacity(0.05),
          hintStyle: TextStyle(color: darkBlue.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
          iconColor: darkBlue,
          prefixIconColor: darkBlue,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: baseWhite,
          foregroundColor: darkBlue,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: darkBlue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: darkBlue,
        colorScheme: const ColorScheme.dark(
          primary: baseWhite, // Container color
          onPrimary: darkBlue, // Text on container
          surface: darkBlue, // Background
          onSurface: baseWhite, // Just text
          primaryContainer: baseWhite,
          onPrimaryContainer: darkBlue,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: baseWhite),
          bodyMedium: TextStyle(color: baseWhite),
          titleLarge: TextStyle(color: baseWhite),
          headlineLarge: TextStyle(color: baseWhite),
          headlineMedium: TextStyle(color: baseWhite),
          headlineSmall: TextStyle(color: baseWhite),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: baseWhite,
            foregroundColor: darkBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: baseWhite.withOpacity(0.1),
          hintStyle: TextStyle(color: baseWhite.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
          iconColor: baseWhite,
          prefixIconColor: baseWhite,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBlue,
          foregroundColor: baseWhite,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: baseWhite),
      ),
      home: const Adminhomescreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String title = 'Material Theme App';

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
