import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'forgot_password_screen.dart';
import '../dashboard/main_navigation_screen.dart';
import '../gymregistration/register.dart';
import '../../core/constants/locationfetch.dart';

const gold = Color(0xFFD5EB45);

const bg = Color(0xff0B0D12);

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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xff0B0D12),
                  Color(0xff141821),
                  Color(0xff1C1F2A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, _controller.value, 1.0],
              ),
            ),

            child: Stack(
              children: [

                /// Glow Effects
                Positioned(
                  top: -80,
                  left: -60,
                  child: glowCircle(gold),
                ),

                Positioned(
                  bottom: -100,
                  right: -60,
                  child: glowCircle(const Color(0xFFD5EB45)),
                ),

                /// LOGIN CARD
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),

                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 25,
                          sigmaY: 25,
                        ),

                        child: Container(
                          padding: const EdgeInsets.all(30),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),

                          child: Form(
                            key: _formKey,

                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                /// APP LOGO
                                Container(
                                  height: 90,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFD5EB45),
                                        Color(0xFFB7D933),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gold.withOpacity(.6),
                                        blurRadius: 30,
                                        spreadRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center,
                                    size: 40,
                                    color: Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  "Trainer Login",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 30),

                                /// EMAIL FIELD
                                textField(
                                  controller: emailController,
                                  hint: "Email Address",
                                  icon: Icons.email,
                                ),

                                const SizedBox(height: 20),

                                /// PASSWORD
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  validator: (v) =>
                                  v!.isEmpty ? "Password required" : null,

                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                        Icons.lock,
                                        color: gold),

                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: gold,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },
                                    ),

                                    hintText: "Password",
                                    hintStyle:
                                    const TextStyle(color: Colors.white38),

                                    filled: true,
                                    fillColor:
                                    Colors.black.withOpacity(0.45),

                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(18),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),

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
                                      style: TextStyle(color: gold),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                /// LOGIN BUTTON
                                glowingButton(),

                                const SizedBox(height: 15),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    const Text(
                                      "Don't have an account?",
                                      style: TextStyle(color: Colors.white70),
                                    ),

                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LocationDetectScreen(

                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Register",
                                        style: TextStyle(
                                          color: gold,
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
        },
      ),
    );
  }

  Widget textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {

    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),

      validator: (v) =>
      v!.isEmpty ? "Field required" : null,

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: gold),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),

        filled: true,
        fillColor: Colors.black.withOpacity(.45),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
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
          colors: [
            Color(0xFFD5EB45),
            Color(0xFFB7D933),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color: gold.withOpacity(.6),
            blurRadius: 25,
            spreadRadius: 1,
          )
        ],
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),

        onPressed: isLoading ? null : login,

        child: isLoading
            ? const CircularProgressIndicator(
          color: Colors.black,
        )
            : const Text(
          "Login",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
        color: color.withOpacity(.25),
      ),
    );
  }
}