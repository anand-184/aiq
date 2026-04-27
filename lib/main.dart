import 'package:aiq/screens/adminScreens/adminHomeScreen.dart';
import 'package:aiq/screens/adminScreens/admin_dashboard.dart';
import 'package:aiq/screens/login_screen.dart';
import 'package:aiq/screens/register_screen.dart';
import 'package:aiq/screens/super_admin_screens/super_admin_dashboard.dart';
import 'package:aiq/theme/apptheme.dart';
import 'package:aiq/viewmodels/super_admin_viewmodel.dart';
import 'package:aiq/viewmodels/admin_viewmodel.dart';
import 'package:aiq/services/analytics_service.dart';
import 'package:aiq/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SuperAdminViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        Provider(create: (_) => AnalyticsService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);

    return MaterialApp(
      title: 'Material Theme App',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      navigatorObservers: [analyticsService.observer],
      home: const SuperAdminDashboard(),
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
   