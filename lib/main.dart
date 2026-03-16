import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/main_navigation_screen.dart';
import 'core/constants/locationfetch.dart';
import 'features/auth/login_screen.dart';
import 'splash/splash_screen.dart';


void main() {
  runApp(const TrainerApp());
}

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (token != null) {

      /// Already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );

    } else {

      /// First time user
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            //builder: (_) => const   LoginScreen (),
          builder: (_) => const SplashScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}