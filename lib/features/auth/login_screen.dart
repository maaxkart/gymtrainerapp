import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'forgot_password_screen.dart';
import '../dashboard/main_navigation_screen.dart';
import '../../core/constants/locationfetch.dart';

const primaryGreen = Color(0xFFD5EB45);
const lightGreen = Color(0xFFD5EB45);
const bgWhite = Color(0xFFF7F9FC);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {

      final response = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => isLoading = false);

      if (response["status"] == "success") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Login failed"),
            backgroundColor: Colors.red,
          ),
        );
      }

    } catch (e) {

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bgWhite,

      body: Stack(
        children: [

          /// 🌿 BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF7F9FC),
                  Color(0xFFE8F5E9),
                  Color(0xFFD0F0E0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🌿 GLOW
          Positioned(
            top: -80,
            left: -60,
            child: glowCircle(primaryGreen),
          ),

          Positioned(
            bottom: -100,
            right: -60,
            child: glowCircle(lightGreen),
          ),

          /// 🧊 CARD
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),

                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

                  child: Container(
                    padding: const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          /// LOGO
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [primaryGreen, lightGreen],
                              ),
                            ),
                            child: const Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Trainer Login",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// EMAIL
                          textField(
                            controller: emailController,
                            hint: "Email Address",
                            icon: Icons.email,
                          ),

                          const SizedBox(height: 20),

                          /// PASSWORD
                          passwordField(),

                          const SizedBox(height: 15),

                          /// FORGOT
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: primaryGreen),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// BUTTON
                          glowingButton(),

                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              const Text(
                                "Don't have an account?",
                                style: TextStyle(color: Colors.black54),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const LocationDetectScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ FIXED TEXT FIELD
  Widget textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,

      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),

      validator: (v) => v!.isEmpty ? "Field required" : null,

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryGreen),

        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(vertical: 16),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  /// PASSWORD FIELD
  Widget passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,

      style: const TextStyle(color: Colors.black),

      validator: (v) =>
      v!.isEmpty ? "Password required" : null,

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: primaryGreen),

        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: primaryGreen,
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),

        hintText: "Password",
        hintStyle: TextStyle(color: Colors.grey.shade600),

        filled: true,
        fillColor: Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primaryGreen,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget glowingButton() {
    return Container(
      width: double.infinity,
      height: 55,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [primaryGreen, lightGreen],
        ),
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),

        onPressed: isLoading ? null : login,

        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget glowCircle(Color color) {
    return Container(
      height: 220,
      width: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(.2),
      ),
    );
  }
}