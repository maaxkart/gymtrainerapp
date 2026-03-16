import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../features/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    scaleAnimation = Tween<double>(begin: 0.6, end: 1.1).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// glowing circle
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.card,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.8),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: AppColors.secondary,
                  ),
                ),

                const SizedBox(height: 30),

                /// App Name
                Text(
                  "POWER GYM",
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Train Hard. Stay Strong.",
                  style: TextStyle(
                    color: AppColors.subText,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 40),

                /// loading indicator
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    color: AppColors.secondary,
                    backgroundColor: AppColors.border,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}