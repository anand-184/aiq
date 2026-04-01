import 'package:aiq/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Explicit global colors provided by the user
    const lightBlue = Color(0xFF95B1EE);
    const baseWhite = Color(0xFFFFFDF5);

    return MaterialApp(
      title: 'Material Theme App',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,// Supports switching based on device
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: baseWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightBlue,
          primary: baseWhite,
          onPrimary: lightBlue,
          primaryContainer: lightBlue,
          onPrimaryContainer: baseWhite,
          surface: baseWhite,
          onSurface: lightBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: baseWhite,
          foregroundColor: lightBlue,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: lightBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightBlue,
          brightness: Brightness.dark,
          primary: lightBlue,
          onPrimary: baseWhite,
          primaryContainer: lightBlue,
          onPrimaryContainer: lightBlue,
          surface: lightBlue,
          onSurface: baseWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: baseWhite,
          foregroundColor: lightBlue
          ,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
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
