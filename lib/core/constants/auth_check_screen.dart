import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/dashboard/main_navigation_screen.dart';
import '../../features/auth/login_screen.dart';
import '../constants/locationfetch.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {

  @override
  void initState() {
    super.initState();
    checkAppState();
  }

  Future<void> checkAppState() async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");
    final gymRegistered = prefs.getBool("gym_registered") ?? false;

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    /// USER LOGGED IN
    if (token != null) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );

    }

    /// GYM REGISTERED BUT NOT LOGGED IN
    else if (gymRegistered) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

    }

    /// FIRST INSTALL
    else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LocationDetectScreen(),
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